# タスクリスト: Week1 初期セットアップ

## 🚨 タスク完全完了の原則

**このファイルの全タスクが完了するまで作業を継続すること**

---

## フェーズ1: Rails new + 基盤整備 (#5)

- [x] Rails 7.2.x アプリを `rails new` で作成する
- [x] Gemfile に必要な gem を全て追加する
  - [x] Production: pg, puma, devise（後工程用に追加のみ）
  - [x] Dev/Test: rspec-rails, factory_bot_rails, faker, pry-rails, rubocop-rails-omakase, brakeman, bundler-audit, simplecov, shoulda-matchers, rspec_junit_formatter, capybara, selenium-webdriver
- [x] `.ruby-version` ファイルを作成する（`3.2.x` 形式）
- [x] `.rubocop.yml` を作成・設定する
- [x] `config/database.yml` を PostgreSQL/Neon 対応に設定する
- [x] `spec/spec_helper.rb` を SimpleCov込みで設定する
- [x] `spec/rails_helper.rb` を設定する（shoulda-matchers, factory_bot）
- [x] `bundle exec rubocop` がエラーなしで通ることを確認

## フェーズ2: TOPページ（LP）の作成 (#6)

- [x] `config/routes.rb` に `root "top#index"` を設定する
- [x] `app/controllers/top_controller.rb` を作成する
- [x] `app/views/top/index.html.erb` を作成する
  - [x] ゲスト用ヘッダー（Yomikiriロゴ）を配置する
  - [x] キャッチコピー「積読を消化する技術」とサービス概要を表示する
  - [x] 「新規登録して始める」ボタンを配置する
  - [x] 「ログイン」ボタンを配置する
  - [x] フッターを配置する
- [x] `app/views/layouts/application.html.erb` を整備する（共通ヘッダー・フッター）
- [x] `app/assets/stylesheets/application.css` を整備する（共通スタイル・CSS変数）
- [x] `app/assets/stylesheets/top.css` を作成する（TOPページBEMスタイル）
- [x] レスポンシブ対応のメディアクエリを実装する（モバイル/タブレット/デスクトップ）

## フェーズ3: デプロイ設定ファイル作成 (#7, #43)

- [x] `Procfile` を作成する
- [x] `render.yaml` を作成する（IaC定義）
- [x] `.env.example` を作成する（環境変数テンプレート）

## フェーズ4: CI パイプライン (#42)

- [x] `.github/workflows/ci.yml` を作成する
  - [x] RuboCop ジョブを設定する
  - [x] Brakeman ジョブを設定する
  - [x] bundler-audit ジョブを設定する
  - [x] RSpec ジョブを設定する（PostgreSQLサービスコンテナ付き）
  - [x] concurrency 設定を追加する
  - [x] Artifact アップロード（テスト結果・カバレッジ）を設定する

## フェーズ5: PRテンプレート・Projects自動化 (#44)

- [x] `.github/pull_request_template.md` を作成する
- [x] `.github/workflows/project-automation.yml` を作成する

## フェーズ6: README整備

- [x] `README.md` にセットアップ手順・環境変数登録手順を記載する

---

## 実装後の振り返り

### 実装完了日
2026-03-08

### 計画と実績の差分

**未実装（人間の手動作業が必要なもの）**:
- GitHub Branch Protection Rules の設定（GitHubウェブUI操作）
- GitHub Secrets の登録（`RAILS_MASTER_KEY`, `PROJECT_TOKEN`）
- Render ダッシュボードでの環境変数・デプロイ設定
- Neon データベース作成と接続文字列の取得
- Render への実際のデプロイ実行

**技術的理由**:
上記はすべてGitHub/Render/NeonのウェブUIまたはAPIトークンが必要な外部サービス操作であり、ファイル操作ツールでは実施不可能。

### 学んだこと
-

### 次回への改善提案
-
