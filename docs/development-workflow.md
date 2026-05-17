# Yomikiri 開発ワークフロー

GitHub Projects #2 を起点に、Issue → ブランチ → PR → 自動テスト → 自動デプロイ までを一本のレーンで回す開発フローです。

---

## 全体像

```
GitHub Projects #2
        │
        │ Issue を "In Progress" へ
        ▼
  feature ブランチ作成
  feature/#番号-機能名
        │
        │ 実装 + コミット
        ▼
  Pull Request 作成
        │
        ├─── GitHub Actions CI ──────────────────┐
        │    ① RuboCop（静的解析）                │
        │    ② RSpec（自動テスト）                 │
        │    ③ Brakeman（セキュリティスキャン）    │
        │    ④ すべて GREEN → マージ可能           │
        └────────────────────────────────────────┘
        │
        │ main へマージ
        ▼
  GitHub Actions CD
  Render へ自動デプロイ
        │
        ▼
  Issue を自動クローズ
  Projects カードを "Done" へ
```

---

## ステップ 1: Issue を起点に作業を始める

### Projects ボードの運用

| ステータス | 意味 | 操作タイミング |
|-----------|------|---------------|
| **Backlog** | 未着手 | Issue 作成時（自動） |
| **In Progress** | 実装中 | ブランチ作成前に手動で移動 |
| **In Review** | PR レビュー中 | PR 作成時（自動化可能） |
| **Done** | 完了・マージ済み | main マージ時（自動） |

### 作業開始の手順

```bash
# 1. Projects ボードで該当 Issue を "In Progress" へ移動
#    https://github.com/users/liverpl1920/projects/2

# 2. ブランチを作成して切り替え
git switch main
git pull origin main
git switch -c feature/#1-rails-setup

# 3. 実装
# ...

# 4. コミット（Issue 番号を必ず含める）
git add .
git commit -m "feat: Rails 7.2 初期セットアップ (#1)"
git push origin feature/#1-rails-setup
```

### ブランチ命名規則

```
feature/#{Issue番号}-{機能の短い説明}

例:
  feature/#1-rails-setup
  feature/#4-devise-user-model
  feature/#12-book-detail
  feature/#21-active-storage
```

### コミットメッセージ規則

```
{type}: {内容} (#{Issue番号})

type の種類:
  feat     新機能
  fix      バグ修正
  style    UI/CSS の変更
  refactor リファクタリング
  test     テストの追加・修正
  docs     ドキュメントの変更
  chore    設定ファイル等の変更

例:
  feat: Devise による User モデル作成 (#4)
  fix: ノルマ計算で期限当日が D=0 になるバグを修正 (#14)
  test: Book モデルのバリデーションテストを追加 (#9)
```

---

## ステップ 2: CI パイプライン（`.github/workflows/ci.yml`）

PR を作成すると自動で以下が走ります。**すべて GREEN にならないとマージ不可**にします。

```yaml
# Yomikiri Rails アプリのリポジトリに配置するファイル
# 場所: .github/workflows/ci.yml

name: CI

on:
  pull_request:
    branches: [main]

concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true

permissions:
  contents: read

jobs:
  # ─────────────────────────────────────────
  # ① 静的解析・セキュリティスキャン (RuboCop / Brakeman / bundler-audit)
  # ─────────────────────────────────────────
  lint-security:
    name: RuboCop & Brakeman & bundler-audit
    runs-on: ubuntu-latest
    timeout-minutes: 10

    steps:
      - uses: actions/checkout@v4

      - name: Ruby をセットアップ
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: .ruby-version   # .ruby-version ファイルで管理
          bundler-cache: true

      - name: RuboCop を実行
        run: bundle exec rubocop --format github

      - name: Brakeman を実行
        run: bundle exec brakeman --no-pager --format github

      - name: bundler-audit を実行（gem 脆弱性スキャン）
        run: |
          gem install bundler-audit --no-document
          bundle-audit check --update

  # ─────────────────────────────────────────
  # ② 自動テスト (RSpec)
  # ─────────────────────────────────────────
  test:
    name: RSpec
    runs-on: ubuntu-latest
    timeout-minutes: 15

    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: yomikiri_test
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    env:
      RAILS_ENV: test
      DATABASE_URL: postgres://postgres:postgres@localhost:5432/yomikiri_test
      RAILS_MASTER_KEY: ${{ secrets.RAILS_MASTER_KEY }}

    steps:
      - uses: actions/checkout@v4

      - name: Ruby をセットアップ
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: .ruby-version
          bundler-cache: true

      - name: DB セットアップ
        run: |
          bundle exec rails db:create
          bundle exec rails db:schema:load

      - name: RSpec を実行
        run: bundle exec rspec --format progress --format RspecJunitFormatter --out tmp/rspec_results.xml

      - name: テスト結果をアップロード
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: rspec-results
          path: tmp/rspec_results.xml

```

### CI に必要な Gem

Rails アプリの `Gemfile` に追加してください。

```ruby
group :development, :test do
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
  gem "brakeman", require: false
  gem "bundler-audit", require: false
end

group :test do
  gem "rspec_junit_formatter"  # CI のテスト結果レポート用
  gem "shoulda-matchers"
end

group :development do
  gem "rubocop-rails-omakase", require: false  # Rails 公式推奨設定
end
```

---

### 定期実行（`.github/workflows/daily_tasks.yml`）

```yaml
name: Daily Tasks

on:
  schedule:
    - cron: '0 15 * * *'  # 毎日JST 00:00 (UTC 15:00)
  workflow_dispatch:       # 失敗時の手動再実行用

jobs:
  daily:
    runs-on: ubuntu-latest
    timeout-minutes: 10

    steps:
      - uses: actions/checkout@v4

      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: .ruby-version
          bundler-cache: true

      - name: ノルマ再計算
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
          RAILS_ENV: production
        run: bundle exec rake daily:recalculate_quota

      - name: 期限イベント生成
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
          RAILS_ENV: production
        run: bundle exec rake daily:generate_deadline_events

      - name: リマインドメール送信（本リリース以降）
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
          SENDGRID_API_KEY: ${{ secrets.SENDGRID_API_KEY }}
          RAILS_ENV: production
        run: bundle exec rake notification:send_reminders
```

---

## ステップ 3: CD パイプライン（Render 自動デプロイ）

### Render の設定

Render の Dashboard で以下を設定すると、**main にマージされるたびに自動デプロイ**が走ります。

1. Render Dashboard → `Yomikiri` → **Settings**
2. **Branch** を `main` に設定
3. **Auto-Deploy** を `Yes` に設定

```yaml
# render.yaml（リポジトリのルートに配置することで IaC 管理できる）

services:
  - type: web
    name: yomikiri
    runtime: ruby
    region: oregon
    branch: main
    buildCommand: |
      bundle install
      bundle exec rails assets:precompile
    preDeployCommand: bundle exec rails db:migrate  # ビルドと分離してデプロイ直前に実行
    startCommand: bundle exec puma -C config/puma.rb
    envVars:
      - key: RAILS_ENV
        value: production
      - key: RAILS_MASTER_KEY
        sync: false          # Render Dashboard で手動設定
      - key: DATABASE_URL
        sync: false          # Neon の接続文字列
      - key: SENDGRID_API_KEY
        sync: false
```

> **Note**: `sync: false` の環境変数は Render Dashboard の Environment タブで手動設定してください。

### Active Storage（S3）反映時の事前チェック（Issue #112 対応）

`feature/#25-active-storage-setup` を main にマージする前に、以下を必ず実施してください。

1. AWS 側で S3 バケットを作成済みであること
2. Render Dashboard の Environment に次を設定済みであること
    - `AWS_ACCESS_KEY_ID`
    - `AWS_SECRET_ACCESS_KEY`
    - `AWS_REGION`（例: `ap-northeast-1`）
    - `AWS_BUCKET`
3. `render.yaml` の `sync: false` は「値は Git 管理せず、Render 側で手動設定する」意味であることを理解していること

上記が未実施のまま `feature/#25-active-storage-setup` をマージすると、本番起動時に環境変数不足で起動不能になるリスクがあります。

### Active Storage 関連ブランチの推奨マージ順序

1. `feature/#25-active-storage-setup`
2. Render の自動デプロイ成功と `/up` 正常応答を確認
3. `feature/#26-cover-image-upload`

順序を逆にすると、`:local` ストレージ運用による再デプロイ時の画像消失リスクが残ります。

### PR レビュー時チェックリスト（Active Storage 反映時）

- [ ] Render Dashboard に `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`, `AWS_BUCKET` が設定済み
- [ ] `feature/#25-active-storage-setup` の反映後に `/up` が正常応答することを確認済み
- [ ] `feature/#26-cover-image-upload` は `feature/#25` のデプロイ確認後にマージする
- [ ] `sync: false` の環境変数が「手動設定前提」であることをレビューで確認済み

---

## ステップ 4: GitHub Project の自動化

### Issue 作成/再オープン時の自動追加 + PRマージ時のDone移動

```yaml
# .github/workflows/project-automation.yml

name: Project Automation

on:
  issues:
    types: [opened, reopened]
  pull_request:
    types: [closed]

jobs:
  # Issue 作成時/再オープン時 → プロジェクトに追加
  add-to-project:
    if: github.event.action == 'opened' || github.event.action == 'reopened'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/add-to-project@v1.0.2
        with:
          project-url: https://github.com/users/liverpl1920/projects/2
          github-token: ${{ secrets.PROJECT_TOKEN }}

  # PR close かつ merge=true のときに linked issue を Done に移動
  move-to-done:
    if: >
      github.event_name == 'pull_request' &&
      github.event.action == 'closed' &&
      github.event.pull_request.merged == true
    runs-on: ubuntu-latest
```

運用ルール:

- PR 作成時（opened）には Project Automation は実行されません。
- Issue の opened/reopened ではプロジェクトへ自動追加されます。
- PR が merged されたときのみ linked issue の Done 移動処理が実行されます。

### PR テンプレートの設定

PR 本文に `Closes #番号` を書くと、マージ時に Issue が自動クローズされ、Projects カードが **Done** に移動します。

```markdown
<!-- .github/pull_request_template.md -->

## 概要

<!-- このPRで何をしたか1〜2行で -->

## 対応 Issue

Closes #

## 実装内容

- [ ]
- [ ]

## 動作確認

- [ ] ローカルで動作確認済み
- [ ] RuboCop エラーなし（`bundle exec rubocop`）
- [ ] RSpec 全件パス（`bundle exec rspec`）

## スクリーンショット（UI変更がある場合）

```

---

## ステップ 5: ブランチ保護ルール（Branch Protection）

GitHub リポジトリの **Settings → Branches → Add rule** で以下を設定します。

| 設定項目 | 値 |
|---------|-----|
| Branch name pattern | `main` |
| Require a pull request before merging | ✅ |
| Require status checks to pass | ✅ |
| Status checks（必須） | `RuboCop & Brakeman & bundler-audit` / `RSpec` |
| Require branches to be up to date | ✅ |
| Do not allow bypassing the above settings | ✅ |

これで **CI が全部 GREEN にならないと main にマージできない**状態になります。

---

## 毎週の開発サイクル（Week ごとの回し方）

```
月曜日
  └── Projects ボードを開いて今週の Issue を確認
  └── 最優先の Issue を "In Progress" へ移動
  └── feature ブランチを作成

火〜金
  └── 実装 → コミット（小さく・頻繁に）
  └── 実装が完了したら PR を作成
  └── CI（RuboCop + Brakeman + bundler-audit + RSpec）を確認
  └── GREEN になったら自分でマージ（卒業制作のため、レビュー待ちは不要）
  └── Render に自動デプロイされることを確認
  └── 次の Issue へ

週末
  └── Projects ボードで今週の Done を確認
  └── 来週の Issue に Story Points と Week を設定（ずれがあれば修正）
```

---

## GitHub Secrets の登録一覧

GitHub リポジトリの **Settings → Secrets and variables → Actions** に登録します。

| Secret 名 | 値 | 用途 |
|----------|----|------|
| `RAILS_MASTER_KEY` | `config/master.key` の中身 | CI でのテスト実行 |
| `PROJECT_TOKEN` | Projects 書き込み権限付き PAT（Classic、`repo` + `project`スコープ） | Project 自動化 |
| `DATABASE_URL` | Neon 接続文字列 | 定期タスク（`daily_tasks.yml`） |
| `SENDGRID_API_KEY` | SendGrid API キー | メール通知定期タスク（本リリース以降） |

---

## セットアップチェックリスト

Rails アプリのリポジトリで以下を完了させてから開発を始めます。

- [ ] `.ruby-version` ファイルを作成（例: `3.2.0`）
- [ ] `Gemfile` に rspec-rails / brakeman / rubocop-rails-omakase を追加
- [ ] `.github/workflows/ci.yml` を作成（上記の内容をコピー）
- [ ] `.github/workflows/project-automation.yml` を作成
- [ ] `.github/pull_request_template.md` を作成
- [ ] `render.yaml` を作成
- [ ] GitHub Secrets に `RAILS_MASTER_KEY` を登録
- [ ] Branch Protection Rules を設定（main を保護）
- [ ] Render の Auto-Deploy を有効化
- [ ] 動作確認：ダミーの PR を作って CI が走ることを確認
