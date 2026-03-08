# 要求定義: Week1 初期セットアップ

## 対象 Issue

| Issue | タイトル | 担当 | SP |
|-------|---------|------|-----|
| #5 | rails new + 初期セットアップ | Copilot | 2 |
| #6 | TOPページ（LP）の作成 | Copilot | 2 |
| #7 | Renderへの初回デプロイ | Copilot | 2 |
| #42 | CI パイプラインの設計・構築 | Copilot（ファイル作成） | - |
| #43 | CD パイプラインの設計・Render 自動デプロイ設定 | Copilot（ファイル作成） | - |
| #44 | ブランチ保護ルール・PR テンプレート・Projects 自動化の設定 | Copilot（ファイル作成） | - |
| #45 | GitHub Secrets・環境変数の登録 | 手順書作成のみ（実作業は人間） | - |

## 実装範囲

### Issue #5: rails new + 初期セットアップ

**実装内容**:
- Rails 7.2.x プロジェクトを作成
- PostgreSQL をデータベースとして設定(Neon接続対応)
- Gemfile に必要な gem を追加
  - Production: `devise`, `pg`, `puma`
  - Development/Test: `rspec-rails`, `factory_bot_rails`, `faker`, `pry-rails`, `rubocop-rails-omakase`, `brakeman`, `shoulda-matchers`, `rspec_junit_formatter`, `capybara`, `selenium-webdriver`
  - `bundler-audit` (CI用)
- `.ruby-version` ファイルを作成（CI参照用）
- `.rubocop.yml` を設定
- `spec/spec_helper.rb` と `spec/rails_helper.rb` を設定（SimpleCov含む）

**完了条件**:
- `rails s` でローカルサーバーが正常起動
- `bundle exec rubocop` エラーなし
- `bundle exec rspec` が実行可能

### Issue #6: TOPページ（LP）の作成

**実装内容**:
- 静的ランディングページ（W-1画面）
- ゲスト用ヘッダー（Yomikiriロゴ）
- キャッチコピー「積読を消化する技術」とサービス概要
- 「新規登録して始める」ボタン（#: Deviseなし段階のためリンク先は仮）
- 「ログイン」ボタン
- フッター
- レスポンシブ対応（モバイル/タブレット/デスクトップ）

**完了条件**:
- `/` にアクセスしてTOPページが表示される
- レスポンシブレイアウトが崩れない

### Issue #7: Renderへの初回デプロイ設定ファイル

**実装内容**:
- `render.yaml` (IaC)の作成（手動でのRender設定の参考用）
- Procfile の作成
- `config/environments/production.rb` の確認・調整

**注意**: 実際のデプロイはRenderダッシュボード操作が必要（手動作業）

### Issue #42: CI パイプライン

**実装内容**:
- `.github/workflows/ci.yml` を作成
- RuboCop / RSpec / Brakeman / bundler-audit の4ジョブ
- PostgreSQLサービスコンテナ設定
- テスト結果をArtifactとしてアップロード

### Issue #43: CD パイプライン

**実装内容**:
- `render.yaml` が #43 の要件を満たすよう設定
- buildCommand / preDeployCommand / startCommand の定義

### Issue #44: ブランチ保護・PRテンプレート

**実装内容**:
- `.github/pull_request_template.md` の作成
- `.github/workflows/project-automation.yml` の作成

### Issue #45: 環境変数（手順書）

**実装内容**:
- `.env.example` の作成（登録すべき環境変数のテンプレート）
- README に環境変数登録手順を記載
