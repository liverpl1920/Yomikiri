# 技術仕様書 (Architecture Design Document)

## テクノロジースタック

### 言語・ランタイム

| 技術 | バージョン | 選定理由 |
|------|-----------|----------|
| Ruby | 3.2.x | Rails 7.2との互換性、豊富なGem、開発速度 |
| PostgreSQL | 16.x | リレーショナルデータの整合性、JSON型サポート、Neonの無料枠 |

### フレームワーク・ライブラリ

| 技術 | バージョン | 用途 | 選定理由 |
|------|-----------|------|----------|
| Ruby on Rails | 7.2.x | Webアプリケーションフレームワーク | MVCアーキテクチャ、Convention over Configuration、豊富なエコシステム |
| Devise | 4.9.x | ユーザー認証 | Railsのデファクトスタンダード、セキュアな実装、豊富な機能 |
| RSpec | 3.12.x | テストフレームワーク | BDD、豊富なマッチャー、読みやすい仕様記述 |
| rubocop-rails-omakase | 1.x | 静的解析・Linter | Rails公式推奨設定、コード品質の維持 |

### インフラ・デプロイ

| 技術 | バージョン | 用途 | 選定理由 |
|------|-----------|------|----------|
| Render | - | Webアプリホスティング | 無料枠、簡単なデプロイ、自動HTTPS、Git連携 |
| Neon | PostgreSQL 16.x | データベースホスティング | 無料枠、自動バックアップ、高速、スケーラブル |
| SendGrid | - | メール送信（本リリース） | 無料枠、高い配信率、APIが使いやすい |
| GitHub Actions | - | CI/CD・定期実行 | 無料枠、Git統合、cronサポート |

### 外部API

| API | 用途 | 選定理由 |
|-----|------|----------|
| Google Calendar API | カレンダー連携（簡易版・自動版） | ユーザーの既存カレンダーを活用、広く使われている |
| openBD API | 書籍情報取得（本リリース） | APIキー不要、日本の書籍情報に強い、無料 |

---

## アーキテクチャパターン

### MVCアーキテクチャ（Rails標準）

```
┌─────────────────────────────────────────┐
│          ユーザー（ブラウザ）             │
└─────────────────┬───────────────────────┘
                  │ HTTP Request
                  ▼
         ┌────────────────┐
         │    Routes      │ ← URLルーティング
         └────────┬───────┘
                  ▼
         ┌────────────────┐
         │  Controllers   │ ← リクエスト処理、ビジネスロジック呼び出し
         └───┬────────┬───┘
             │        │
             ▼        ▼
    ┌────────────┐ ┌────────────┐
    │   Models   │ │   Views    │
    │(ビジネス   │ │(プレゼン   │
    │ ロジック)  │ │ テーション)│
    └──────┬─────┘ └────────────┘
           │
           ▼
    ┌──────────────┐
    │ PostgreSQL   │ ← データ永続化
    └──────────────┘
```

#### レイヤーの責務

**Routes（ルーティング層）**:
- **責務**: URLからコントローラーアクションへのマッピング
- **許可される操作**: HTTPメソッドとパスの定義
- **実装ファイル**: `config/routes.rb`

**Controllers（コントローラー層）**:
- **責務**: HTTPリクエストの受付、パラメータのバリデーション、モデルの呼び出し、ビューへのデータ渡し
- **許可される操作**: モデルメソッドの呼び出し、サービスオブジェクトの利用
- **禁止される操作**: 直接的なSQL実行、複雑なビジネスロジックの記述
- **実装ディレクトリ**: `app/controllers/`

**Models（モデル層）**:
- **責務**: ビジネスロジックの実装、データのバリデーション、データベースとのやり取り
- **許可される操作**: データベースクエリ、計算ロジック、関連の定義
- **禁止される操作**: HTTPレスポンスの生成、ビューへの直接アクセス
- **実装ディレクトリ**: `app/models/`

**Views（ビュー層）**:
- **責務**: HTMLの生成、データの表示
- **許可される操作**: ERBテンプレートでのデータ表示、ヘルパーメソッドの利用
- **禁止される操作**: ビジネスロジックの実装、データベースへの直接アクセス
- **実装ディレクトリ**: `app/views/`

#### サービス層（オプション）

複雑なビジネスロジックはサービスオブジェクトに切り出します:

```ruby
# app/services/google_calendar_service.rb
class GoogleCalendarService
  def self.generate_url(book, duration_minutes = 30)
    # カレンダーURL生成ロジック
  end
end
```

**責務**: 複数のモデルにまたがる処理、外部API連携
**実装ディレクトリ**: `app/services/`

---

## フロントエンドアーキテクチャ

### Hotwire（Rails 7 標準）

Rails 7.2 のデフォルトフロントエンド構成として **Hotwire**（Turbo + Stimulus）を採用します。

| 技術 | 用途 | Yomikiriでの利用箇所 |
|------|------|----------------------|
| **Turbo Drive** | ページ遷移の高速化（SPAライクな体験） | 全ページ遷移 |
| **Turbo Frames** | ページの一部更新 | 進捗更新フォーム、ノルマ表示の部分更新 |
| **Turbo Streams** | サーバープッシュによる画面更新 | 進捗更新後のノルマ再計算結果表示 |
| **Stimulus** | 軽量なJSコントローラー | 進捗入力の±ボタン、賞味期限ビジュアライザー |

#### Stimulus コントローラー一覧（MVP）

```
app/javascript/controllers/
├── progress_controller.js       # 今日読んだページ数の±ボタン・入力制御
└── visualizer_controller.js     # 賞味期限ビジュアライザーのCSSクラス制御
```

#### 設計方針
- **JavaScript 最小化**: Hotwire で解決できる UI は Stimulus/Turbo を優先
- **フルJS置換なし**: React/Vue は使用しない（Rails 標準構成を維持）
- **Importmap**: Node.js ビルドステップなし（`rails importmap:install` 済み）

#### CSS 方針
- **BEM記法のコンポーネント指向CSS**: Tailwind は使用せず、`app/assets/stylesheets/` に配置
- **賞味期限ビジュアライザー向けクラス**（`visualizer.css`）:

```css
/* 残り日数に応じてサーバーサイドでCSSクラスを付与し、フィルターを適用 */
.book-cover--days-7  { filter: sepia(30%);  opacity: 0.90; }
.book-cover--days-3  { filter: sepia(60%);  opacity: 0.70; }
.book-cover--days-1  { filter: sepia(100%); opacity: 0.50; }
.book-cover--overdue { filter: sepia(100%); opacity: 0.30; }
```

詳細な命名規則とCSS規約は [docs/development-guidelines.md](development-guidelines.md) を参照してください。

---

## タイムゾーン設定

**重要**: バックグラウンド処理・期限判定は JST（日本標準時）を基準とします。

```ruby
# config/application.rb
config.time_zone = 'Tokyo'                    # Railsのデフォルトタイムゾーン
config.active_record.default_timezone = :local # DBへの保存もローカル時刻
```

| 処理 | タイムゾーン | 注意事項 |
|------|------------|----------|
| `Date.today` / `Time.current` | JST（Tokyo） | `config.time_zone = 'Tokyo'`により自動適用 |
| GitHub Actions cron | UTC | `'0 15 * * *'` = JST 00:00 に換算して設定 |
| DB保存（datetime型） | JST | `default_timezone = :local` で JST で保存 |
| `deadline` カラム（date型） | 日付のみ | タイムゾーン非依存 |

---

## 書影（カバー画像）の管理方針

### MVP フェーズ

- **Active Storage（S3）を主系として使用**: `Book` の `has_one_attached :cover_image` でユーザーアップロードを保持
- `books.cover_image_url` は外部URL書影の補助経路として併用
- 表示時は `cover_image` 添付を優先し、未添付時に `cover_image_url` を利用
- production では S3 必須（`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`, `AWS_S3_BUCKET`）。不足時は fail-fast で起動失敗
- 画像読み込み失敗時は UI でプレースホルダー表示へフォールバック

```ruby
# 書影表示ヘルパー例
def book_cover_url(book)
  book.cover_image_url.presence || asset_path('placeholder_book.png')
end
```

### 運用上の注意点

| 項目 | 方針 |
|------|------|
| production ストレージ | `:amazon` 固定（`:local` フォールバック禁止） |
| 環境変数不足 | 起動時に例外を発生させ、誤設定状態で運用しない |
| 外部URL書影 | リンク切れや取得失敗の可能性があるため UI フォールバックを適用 |

---

## データ永続化戦略

### ストレージ方式

| データ種別 | ストレージ | フォーマット | 理由 |
|-----------|----------|-------------|------|
| ユーザー情報 | PostgreSQL (users) | リレーショナル | 正規化、外部キー制約、トランザクション |
| 積読本情報 | PostgreSQL (books) | リレーショナル | ユーザーとの関連、複雑なクエリ |
| 読書記録 | PostgreSQL (reading_logs) | リレーショナル | 本との関連、時系列データ |
| セッション | Rails標準（Cookie） | 暗号化Cookie | ステートレス、スケーラブル |

### バックアップ戦略

**Neonの自動バックアップ**:
- **頻度**: 自動（Neonによる継続的バックアップ）
- **保存先**: Neonのバックアップストレージ
- **世代管理**: ポイントインタイムリカバリ（PITR）対応
- **復元方法**: Neon管理画面から任意の時点に復元可能

**ローカル開発環境**:
```bash
# データベースダンプ（週次）
pg_dump yomikiri_development > backup_$(date +%Y%m%d).sql

# 復元
psql yomikiri_development < backup_YYYYMMDD.sql
```

---

## パフォーマンス要件

### レスポンスタイム

| 操作 | 目標時間 | 測定環境 |
|------|---------|---------|
| トップページ表示 | 2秒以内 | 初回アクセス、Rails起動済み |
| 一覧画面（100冊） | 1秒以内 | N+1クエリなし、インデックス適用済み |
| 詳細画面表示 | 1秒以内 | 関連データpreload済み |
| 進捗更新 | 500ms以内 | ノルマ再計算含む |
| ノルマ計算 | 100ms以内 | Rubyのメモリ内計算 |

### リソース使用量

| リソース | 上限 | 理由 |
|---------|------|------|
| メモリ（Render） | 512MB | 無料枠の制限、100ユーザー想定で十分 |
| データベース容量 | 1GB | Neon無料枠、100ユーザー×平均20冊×1KB/冊 ≈ 2MB |
| レスポンスサイズ | 1MB以内/ページ | モバイルユーザーを考慮 |

### パフォーマンス最適化戦略

**データベースクエリ最適化**:
```ruby
# ❌ N+1問題
@books = current_user.books
@books.each { |book| book.reading_logs.count }

# ✅ includes で一括取得
@books = current_user.books.includes(:reading_logs)
```

**インデックス設定**:
```ruby
# db/migrate/xxx_add_indexes.rb
add_index :books, :user_id
add_index :books, :deadline
add_index :books, [:user_id, :deadline]  # 複合インデックス
```

**キャッシュ戦略（将来）**:
- フラグメントキャッシュ: 書影、一覧ページの部分キャッシュ
- ページキャッシュ: 静的な説明ページ

---

## セキュリティアーキテクチャ

### データ保護

**パスワード管理**:
- **暗号化**: bcrypt（Devise標準）
- **ストレッチング**: コスト係数12（デフォルト）
- **ソルト**: ユーザーごとにランダム生成

**通信の暗号化**:
- **HTTPS**: Renderで自動対応（Let's Encrypt証明書）
- **Cookie**: `secure: true`, `httponly: true`

**機密情報管理**:
```ruby
# config/credentials.yml.enc（暗号化）
sendgrid:
  api_key: <%= ENV['SENDGRID_API_KEY'] %>

google:
  client_id: <%= ENV['GOOGLE_CLIENT_ID'] %>
  client_secret: <%= ENV['GOOGLE_CLIENT_SECRET'] %>
```

### 入力検証

**Strong Parameters**:
```ruby
def book_params
  params.require(:book).permit(
    :title, :author, :total_pages, :target_pages,
    :current_page, :deadline, :cover_image_url
  )
end
```

**バリデーション**:
```ruby
validates :title, presence: true, length: { maximum: 255 }
validates :total_pages, numericality: { greater_than: 0, only_integer: true }
validate :deadline_cannot_be_in_the_past
```

**XSS対策**:
- ERBで自動エスケープ: `<%= @book.title %>`
- HTMLを出力する場合は明示的に: `<%== sanitize(@book.description) %>`

**CSRF対策**:
- Rails標準機能: `protect_from_forgery with: :exception`
- フォームに自動挿入: `<%= form_with model: @book %>`

**SQLインジェクション対策**:
- ActiveRecordを使用（パラメータ化クエリ）
- 生SQLは避ける

---

## スケーラビリティ設計

### データ増加への対応

**想定データ量**:
- ユーザー数: 100人（MVP）→ 1,000人（本リリース）
- 1ユーザーあたり平均20冊
- 合計: 2,000冊（MVP）→ 20,000冊（本リリース）

**パフォーマンス劣化対策**:
1. **インデックスの設定**: user_id, deadline, status
2. **スコープの活用**: `active`（読了以外）でデータを絞る
3. **ペジネーション**: 一覧画面で1ページ50冊まで表示
4. **アーカイブ機能**: 読了から1年経過した本を別テーブルへ（将来）

**データベーススケーリング戦略（将来）**:
- **垂直スケーリング**: Neonの有料プランへ移行
- **読み取りレプリカ**: 読み取り専用のスレーブDB追加
- **パーティショニング**: ユーザーIDでテーブル分割

### 機能拡張性

**プラグインシステム（将来）**:
- 読書スピード計測機能
- 読了シェア機能のカスタマイズ
- タイムライン表示のフィルタリング

**API拡張性（将来）**:
```ruby
namespace :api do
  namespace :v1 do
    resources :books, only: [:index, :show, :create, :update]
  end
end
```

---

## テスト戦略

### テストピラミッド

```
        /\
       /E2\     ← System Specs（数件）
      /────\
     /  統合 \   ← Request Specs（主要フロー）
    /────────\
   /    単体   \  ← Model Specs（全ビジネスロジック）
  /────────────\
```

### ユニットテスト（Model Specs）

**対象**: モデルのビジネスロジック、バリデーション
**フレームワーク**: RSpec
**カバレッジ目標**: 90%以上

**計測方法**: SimpleCov

```ruby
# Gemfile
group :test do
  gem 'simplecov', require: false
end

# spec/spec_helper.rb
require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/spec/'
  minimum_coverage 80
end
```

> CI では `coverage/` ディレクトリをアーティファクトとして保存し、カバレッジ低下を追跡します。

```ruby
RSpec.describe Book, type: :model do
  describe '#calculate_daily_quota' do
    it '切り上げで計算する' do
      book = build(:book, target_pages: 300, current_page: 119, deadline: 3.days.from_now.to_date)
      # 残ページ181 / 残日数4（今日含む）= 45.25 → ceil = 46
      expect(book.calculate_daily_quota).to eq(46)
    end
  end
end
```

### 統合テスト（Request Specs）

**対象**: コントローラーのアクション、HTTPレスポンス
**フレームワーク**: RSpec
**カバレッジ目標**: 主要フローを網羅

```ruby
# spec/requests/books_spec.rb
RSpec.describe 'Books', type: :request do
  describe 'POST /books' do
    it '本が作成される' do
      expect {
        post books_path, params: valid_params
      }.to change(Book, :count).by(1)
    end
  end
end
```

### E2Eテスト（System Specs）

**対象**: ユーザーの操作フロー、JavaScriptの動作
**フレームワーク**: RSpec + Capybara
**カバレッジ目標**: 主要ユースケース3-5件

```ruby
# spec/system/books_spec.rb
RSpec.describe 'Books', type: :system do
  it 'ユーザーは本を登録できる' do
    visit new_book_path
    fill_in 'タイトル', with: 'リーダブルコード'
    click_button '登録する'
    expect(page).to have_content('本を登録しました')
  end
end
```

---

## 技術的制約

### 環境要件

**サーバー環境（Render）**:
- Ruby 3.2.x
- PostgreSQL 16.x
- 最小メモリ: 512MB
- 最小ディスク容量: 1GB

**ブラウザ対応**:
- Chrome 最新版
- Firefox 最新版
- Safari 最新版
- Edge 最新版
- モバイルブラウザ（iOS Safari, Chrome Mobile）

**必要な外部依存**:
- Google Calendar（カレンダー連携使用時）
- SendGrid（メール通知使用時、本リリース）

### パフォーマンス制約

- **同時接続数**: 100接続まで（Render無料枠）
- **レスポンスタイム**: 2秒以内（初回）、1秒以内（以降）
- **データベース接続数**: 20接続まで（Neon無料枠）

### セキュリティ制約

- **パスワード**: 最低6文字（Devise標準）
- **セッション有効期限**: ブラウザ終了まで（Railsデフォルト）。「ログインを保持する」にチェックした場合のみDevise `rememberable` により2週間の永続Cookie（Remember Me機能）
- **HTTPS必須**: 本番環境では常にHTTPS

---

## 依存関係管理

### Gemfile（主要なGem）

| Gem | 用途 | バージョン管理方針 |
|-----|------|--------------------|
| rails | フレームワーク | `~> 7.2.0`（メジャーバージョン固定） |
| pg | PostgreSQLドライバ | `~> 1.5`（マイナーバージョン固定） |
| devise | 認証 | `~> 4.9`（マイナーバージョン固定） |
| rspec-rails | テスト | `~> 6.0`（開発環境のみ） |
| factory_bot_rails | テストデータ生成 | `~> 6.2`（開発・テスト環境のみ） |
| capybara | System Specs（ブラウザ操作） | `~> 3.39`（テスト環境のみ） |
| selenium-webdriver | System Specsブラウザドライバ | `~> 4.0`（テスト環境のみ） |
| rubocop-rails-omakase | Linter | `~> 1.0`（開発環境のみ） |

**更新方針**:
- セキュリティパッチ: 即座に適用（`bundle update [gem]`）
- マイナーバージョン: 四半期ごとに検討
- メジャーバージョン: 慎重に検討、テスト実施後に適用

---

## デプロイ戦略

### 継続的デプロイ（CD）

```
Git Push → GitHub → Render自動デプロイ
```

**トリガー**: `main`ブランチへのプッシュ
**デプロイ時間**: 3-5分
**ダウンタイム**: ほぼゼロ（Renderのゼロダウンタイムデプロイ）

**CI パイプライン（PR時）**: RuboCop + Brakeman + bundler-audit + RSpec がすべて GREEN の場合のみマージ可能。詳細は [docs/development-workflow.md](development-workflow.md) を参照。

### デプロイフロー

1. **開発**: `feature`ブランチで実装
2. **テスト**: GitHub Actionsで自動テスト実行
3. **レビュー**: Pull Requestでコードレビュー
4. **マージ**: `main`ブランチへマージ
5. **自動デプロイ**: Renderが自動的にデプロイ
6. **確認**: 本番環境で動作確認

### ロールバック戦略

**Renderダッシュボードから**:
- 過去のデプロイを選択して再デプロイ
- 1-2分でロールバック完了

**Gitから**:
```bash
# 直前のコミットに戻す
git revert HEAD
git push origin main
# Renderが自動デプロイ
```

---

## バックグラウンド処理アーキテクチャ

### 定期実行（GitHub Actions Cron）

Yomikiri の定期タスクは GitHub Actions の `schedule` イベントで実行します。
**GitHub Actions の cron は UTC 基準**のため、JST = UTC + 9時間 で換算します。

| 実行時刻（JST） | cron 式（UTC） | タスク |
|----------------|--------------|-------|
| 毎日 00:00 | `0 15 * * *` | ノルマ再計算 / 期限3日前イベント生成 / リマインドメール送信 |

```yaml
# .github/workflows/daily_tasks.yml
name: Daily Background Tasks

on:
  schedule:
    - cron: '0 15 * * *'   # JST 00:00:00 (UTC 15:00)
  workflow_dispatch:         # 失敗時の手動再実行に対応

jobs:
  run_tasks:
    runs-on: ubuntu-latest
    timeout-minutes: 10

    steps:
      - uses: actions/checkout@v4

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version-file: '.ruby-version'
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

### 失敗時の検知と対応

- **GitHub Actions の通知機能**で失敗を自動検知（メール通知）
- `workflow_dispatch` で手動再実行が可能
- GitHub Actions の「Re-run failed jobs」ボタンで部分的な再実行も可能

### 定期処理のロジック（Rake tasks）

```ruby
# lib/tasks/daily.rake
namespace :daily do
  desc 'ノルマを再計算する（毎日 JST 00:00 実行）'
  task recalculate_quota: :environment do
    count = Book.active.count
    DailyQuotaCalculatorService.recalculate_all
    Rails.logger.info("ノルマ再計算完了: #{count}冊")
  end

  desc '期限3日前イベントを生成する'
  task generate_deadline_events: :environment do
    target_date = Date.today + 3.days  # JST 基準
    books = Book.active.where(deadline: target_date)
    books.each do |book|
      next if Event.exists?(book: book, event_type: :deadline_approaching)
      Event.create!(book: book, user: book.user, event_type: :deadline_approaching, occurred_at: Time.current)
    end
    Rails.logger.info("期限3日前イベント生成: #{books.count}件")
  end
end
```
#### Event モデルのスキーマ定義

```ruby
# db/migrate/xxx_create_events.rb
create_table :events do |t|
  t.references :user, null: false, foreign_key: true
  t.references :book, null: false, foreign_key: true
  t.integer    :event_type, null: false  # 0: registered, 1: deadline_approaching, 2: completed
  t.datetime   :occurred_at, null: false
  t.timestamps
end
add_index :events, [:book_id, :event_type], unique: true
```

```ruby
# app/models/event.rb
class Event < ApplicationRecord
  belongs_to :user
  belongs_to :book

  enum event_type: { registered: 0, deadline_approaching: 1, completed: 2 }

  validates :event_type, presence: true
  validates :occurred_at, presence: true
end
```
---

## 監視・ロギング

### アプリケーションログ

**本番環境（Render）**:
- `log/production.log`
- Renderダッシュボードでリアルタイム閲覧可能
- 過去7日間のログを保持

**ログレベル**:
- ERROR: エラー発生時（例外、データベースエラー）
- WARN: 警告（バリデーションエラー、非推奨機能の使用）
- INFO: 重要なイベント（ユーザー登録、本登録、読了）
- DEBUG: デバッグ情報（開発環境のみ）

### エラー監視（将来）

**Sentry導入を検討**:
- リアルタイムエラー通知
- スタックトレース
- ユーザーコンテキスト（どのユーザーでエラーが発生したか）

---

## まとめ

Yomikiriのアーキテクチャは、以下の原則に基づいて設計されています:

1. **シンプルさ**: Rails標準のMVCアーキテクチャを採用
2. **セキュリティ**: Devise、HTTPS、入力検証で多層防御
3. **スケーラビリティ**: インデックス、キャッシュ、スコープで将来の成長に対応
4. **保守性**: テストピラミッド、静的解析、明確なレイヤー分離
5. **開発速度**: Rails エコシステム、自動デプロイ、無料インフラ

この設計により、MVP から本リリースへの段階的な成長をサポートし、
長期的な保守性とスケーラビリティを確保します。
