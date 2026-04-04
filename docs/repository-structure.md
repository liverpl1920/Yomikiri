# リポジトリ構造定義書 (Repository Structure Document)

## ディレクトリ構造概要

```
Yomikiri/
├── .github/              # GitHub設定、CI/CD、プロンプト、スキル
├── .steering/            # 作業単位のドキュメント（日付_タスク名/）
├── app/                  # Railsアプリケーション本体
├── bin/                  # 実行可能スクリプト
├── config/               # 設定ファイル
├── db/                   # データベース関連
├── docs/                 # 永続的ドキュメント
├── lib/                  # 共通ライブラリ
├── log/                  # ログファイル
├── public/               # 静的ファイル
├── spec/                 # テストコード（RSpec）
├── storage/              # Active Storage用
├── tmp/                  # 一時ファイル
├── vendor/               # サードパーティライブラリ
├── .gitignore            # Git除外設定
├── .rubocop.yml          # RuboCop設定
├── Gemfile               # Gem依存関係
├── Gemfile.lock          # Gemバージョン固定
├── Procfile              # Render用プロセス定義
├── Rakefile              # Rake tasks
└── README.md             # プロジェクト説明
```

---

## `.github/` - GitHub設定

```
.github/
├── copilot-instructions.md   # GitHub Copilot用プロジェクトメモリ
├── workflows/                # GitHub Actions定義
│   ├── ci.yml                # テスト・Lint実行
│   └── daily_tasks.yml       # 定期実行（ノルマ再計算・通知）
├── prompts/                  # カスタムプロンプト
│   ├── setup-project.prompt.md   # 初回セットアップ
│   ├── add-feature.prompt.md     # 新機能追加
│   └── review-docs.prompt.md     # ドキュメントレビュー
├── skills/                   # スキル定義
│   ├── steering/
│   │   └── SKILL.md          # ステアリングファイル管理
│   ├── prd-writing/
│   │   └── SKILL.md
│   ├── functional-design/
│   │   └── SKILL.md
│   ├── architecture-design/
│   │   └── SKILL.md
│   ├── repository-structure/
│   │   └── SKILL.md
│   ├── development-guidelines/
│   │   └── SKILL.md
│   └── glossary-creation/
│       └── SKILL.md
└── agents/                   # エージェント定義
    ├── doc-reviewer.md       # ドキュメントレビューエージェント
    └── implementation-validator.md  # 実装検証エージェント
```

### ファイル詳細

**`.github/workflows/ci.yml`**:
- **目的**: プルリクエスト時の自動テスト
- **内容**: RSpec実行、RuboCop実行
- **トリガー**: PR作成時、プッシュ時

**`.github/workflows/daily_tasks.yml`**:
- **目的**: 毎日の定期処理
- **内容**: ノルマ再計算、期限イベント生成、通知送信
- **トリガー**: 毎日JST 00:00（cron: `0 15 * * *` ← UTCで設定）

---

## `.steering/` - 作業単位のドキュメント

```
.steering/
├── 20250115-user-authentication/
│   ├── requirements.md       # 作業要求内容
│   ├── design.md             # 実装アプローチ
│   └── tasklist.md           # タスクリスト
├── 20250116-book-crud/
│   ├── requirements.md
│   ├── design.md
│   └── tasklist.md
└── ...
```

### 命名規則

- **形式**: `YYYYMMDD-[タスク名]/`
- **例**: `20250115-add-google-calendar`
- **内容**: 各作業に`requirements.md`, `design.md`, `tasklist.md`の3ファイル

---

## `app/` - Railsアプリケーション本体

```
app/
├── assets/                   # CSS, 画像
│   ├── config/               # Asset Pipeline設定
│   ├── images/               # 画像ファイル
│   └── stylesheets/          # CSSファイル
│       ├── application.css   # メインCSS
│       ├── books.css         # 本一覧・詳細
│       └── visualizer.css    # 賞味期限ビジュアライザー
├── javascript/               # JavaScriptファイル（Importmap）
│   └── controllers/          # Stimulus コントローラー
│       ├── application.js    # エントリーポイント
│       ├── progress_controller.js     # 進捗入力±ボタン
│       └── visualizer_controller.js   # 賞味期限ビジュアライザー
├── controllers/              # コントローラー
│   ├── application_controller.rb
│   ├── books_controller.rb   # 本のCRUD
│   ├── calendar_controller.rb  # カレンダー連携（簡易版・自動版）
│   ├── home_controller.rb    # トップページ
│   └── users/                # Devise customization
│       ├── registrations_controller.rb
│       └── sessions_controller.rb
├── helpers/                  # ビューヘルパー
│   ├── application_helper.rb
│   ├── books_helper.rb       # ノルマ表示、期限フォーマット
│   └── calendar_helper.rb    # カレンダーURL生成
├── models/                   # モデル
│   ├── application_record.rb
│   ├── user.rb               # ユーザー（Devise）
│   ├── book.rb               # 積読本
│   └── reading_log.rb        # 読書記録（本リリース）
├── services/                 # サービスオブジェクト
│   ├── google_calendar_service.rb     # カレンダーURL生成・自動挿入
│   ├── daily_quota_calculator_service.rb  # ノルマ一括再計算
│   └── notification_service.rb        # メール通知（本リリース）
├── views/                    # ビュー
│   ├── layouts/
│   │   ├── application.html.erb   # 全ページ共通
│   │   └── _header.html.erb       # ヘッダー
│   ├── home/
│   │   └── index.html.erb         # トップページ
│   ├── books/
│   │   ├── index.html.erb         # 一覧
│   │   ├── show.html.erb          # 詳細
│   │   ├── new.html.erb           # 新規登録
│   │   ├── edit.html.erb          # 編集
│   │   └── _form.html.erb         # フォーム部分テンプレート
│   ├── devise/                    # Devise views
│   │   ├── registrations/
│   │   │   ├── new.html.erb       # サインアップ
│   │   │   └── edit.html.erb      # プロフィール編集
│   │   └── sessions/
│   │       └── new.html.erb       # ログイン
│   └── shared/
│       └── _flash_messages.html.erb  # フラッシュメッセージ
└── mailers/                  # メーラー（本リリース）
    ├── application_mailer.rb
    └── reminder_mailer.rb    # リマインドメール
```

### 主要ファイル詳細

#### `app/models/book.rb`

**責務**: 積読本のビジネスロジック

```ruby
class Book < ApplicationRecord
  belongs_to :user
  has_many :reading_logs, dependent: :destroy

  enum status: { unread: 0, reading: 1, completed: 2 }

  validates :title, presence: true, length: { maximum: 255 }
  validates :total_pages, numericality: { greater_than: 0, only_integer: true }
  validates :target_pages, numericality: { greater_than: 0, only_integer: true }
  validates :current_page, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validate :deadline_cannot_be_in_the_past

  scope :active, -> { where.not(status: :completed) }
  scope :by_deadline, -> { order(deadline: :asc) }

  # ノルマ計算: ⌈残ページ / 残日数⌉
  def calculate_daily_quota
    remaining_pages = target_pages - current_page
    remaining_days = days_until_deadline
    return 0 if remaining_days <= 0 || remaining_pages <= 0
    (remaining_pages.to_f / remaining_days).ceil
  end

  # 残日数（今日を含む）
  def days_until_deadline
    return 0 if deadline.nil? || deadline < Date.today
    (deadline - Date.today).to_i + 1
  end
end
```

#### `app/models/reading_log.rb`

**責務**: 日々の読書量を記録し、進捗更新履歴を保持

```ruby
class ReadingLog < ApplicationRecord
  belongs_to :book

  validates :pages_read, numericality: { greater_than: 0, only_integer: true }
  validates :read_at, presence: true
end
```

#### `app/controllers/books_controller.rb`

**責務**: 本のCRUD操作、進捗更新

```ruby
class BooksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_book, only: [:show, :edit, :update, :destroy, :update_progress, :change_deadline, :complete]

  def index
    @books = current_user.books.active.by_deadline
  end

  def show
    @daily_quota = @book.calculate_daily_quota
    @reading_logs = @book.reading_logs.order(read_at: :desc).limit(10)
  end

  def create
    @book = current_user.books.build(book_params)
    if @book.save
      redirect_to books_path, notice: '本を登録しました'
    else
      render :new
    end
  end

  def update_progress
    pages_read = params[:pages_read].to_i
    new_current_page = [@book.current_page + pages_read, @book.target_pages].min

    if pages_read <= 0
      redirect_to @book, alert: '読んだページ数を入力してください'
      return
    end

    @book.update(current_page: new_current_page)
    @book.reading_logs.create(pages_read: pages_read, read_at: Date.today)

    if new_current_page >= @book.target_pages
      redirect_to @book, notice: "進捗を更新しました（+#{pages_read}ページ）。読了にできます！"
    else
      redirect_to @book, notice: "進捗を更新しました（+#{pages_read}ページ）"
    end
  end

  private

  def book_params
    params.require(:book).permit(
      :title, :author, :total_pages, :target_pages,
      :current_page, :deadline, :cover_image_url
    )
  end

  def set_book
    @book = current_user.books.find(params[:id])
  end
end
```

#### `app/services/google_calendar_service.rb`

**責務**: Googleカレンダー連携（簡易版: URL生成）

```ruby
class GoogleCalendarService
  def self.generate_url(book, duration_minutes = 30)
    base_url = 'https://calendar.google.com/calendar/render'
    # duration は HHMM 形式（例: 30分 → "0030"）
    duration_hhmm = format('%02d%02d', duration_minutes / 60, duration_minutes % 60)
    params = {
      action: 'TEMPLATE',
      text: "【読書】#{book.title}",
      details: "今日のノルマ: #{book.daily_quota}ページ\n残り: #{book.remaining_pages}ページ",
      duration: duration_hhmm
    }
    "#{base_url}?#{params.to_query}"
  end
end
```

#### `app/services/daily_quota_calculator_service.rb`

**責務**: 全ユーザーのノルマを一括再計算（定期実行用）

```ruby
class DailyQuotaCalculatorService
  def self.recalculate_all
    Book.active.find_each do |book|
      book.daily_quota = book.calculate_daily_quota
      book.save(validate: false)
    end
  end

  def self.recalculate_for_book(book)
    book.daily_quota = book.calculate_daily_quota
    book.save(validate: false)
  end
end
```

---

## `config/` - 設定ファイル

```
config/
├── application.rb            # Rails全体設定
├── boot.rb                   # ブートストラップ
├── cable.yml                 # Action Cable設定
├── credentials.yml.enc       # 暗号化された秘密情報
├── database.yml              # データベース接続設定
├── environment.rb            # 環境読み込み
├── puma.rb                   # Pumaサーバー設定
├── routes.rb                 # ルーティング定義
├── storage.yml               # Active Storage設定
├── environments/             # 環境別設定
│   ├── development.rb        # 開発環境
│   ├── test.rb               # テスト環境
│   └── production.rb         # 本番環境
├── initializers/             # 初期化処理
│   ├── devise.rb             # Devise設定
│   ├── inflections.rb        # 単語の複数形設定
│   └── assets.rb             # Asset Pipeline設定
└── locales/                  # 国際化（i18n）
    ├── ja.yml                # 日本語翻訳
    └── devise.ja.yml         # Devise日本語翻訳
```

### 主要ファイル詳細

#### `config/routes.rb`

```ruby
Rails.application.routes.draw do
  devise_for :users

  root 'home#index'

  resources :books do
    member do
      patch :update_progress      # 進捗更新
      patch :change_deadline      # 期限変更
      patch :complete             # 読了
    end

    resource :calendar, only: [], controller: 'calendar' do
      get :add                    # GoogleカレンダーURL生成
    end
  end
end
```

#### `config/database.yml`

```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: yomikiri_development

test:
  <<: *default
  database: yomikiri_test

production:
  <<: *default
  url: <%= ENV['DATABASE_URL'] %>
```

---

## `db/` - データベース関連

```
db/
├── migrate/                  # マイグレーションファイル
│   ├── 20250101000000_devise_create_users.rb
│   ├── 20250102000000_create_books.rb
│   ├── 20250103000000_add_indexes_to_books.rb
│   └── 20250104000000_create_reading_logs.rb
├── schema.rb                 # データベーススキーマ（自動生成）
└── seeds.rb                  # 初期データ
```

### マイグレーション例

#### `db/migrate/20250102000000_create_books.rb`

```ruby
class CreateBooks < ActiveRecord::Migration[7.2]
  def change
    create_table :books do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.string :author
      t.integer :total_pages, null: false
      t.integer :target_pages, null: false
      t.integer :current_page, default: 0, null: false
      t.date :deadline, null: false
      t.string :cover_image_url
      t.integer :status, default: 0, null: false
      t.integer :daily_quota, default: 0
      t.integer :extension_count, default: 0, null: false
      t.datetime :completed_at
      t.boolean :shared, default: false, null: false

      t.timestamps
    end

    add_index :books, :user_id
    add_index :books, :deadline
    add_index :books, [:user_id, :deadline]
  end
end
```

---

## `docs/` - 永続的ドキュメント

```
docs/
├── idea/                     # アイデア・下書き
│   └── initial-requirements.md
├── product-requirements.md   # プロダクト要求定義書（PRD）
├── functional-design.md      # 機能設計書
├── architecture.md           # 技術仕様書
├── repository-structure.md   # リポジトリ構造定義書
├── development-guidelines.md # 開発ガイドライン
└── glossary.md               # 用語集
```

---

## `spec/` - テストコード（RSpec）

```
spec/
├── rails_helper.rb           # Rails用RSpec設定
├── spec_helper.rb            # RSpec基本設定
├── support/                  # テストヘルパー
│   ├── factory_bot.rb        # FactoryBot設定
│   └── devise.rb             # Deviseテストヘルパー
├── factories/                # FactoryBot定義
│   ├── users.rb
│   └── books.rb
├── models/                   # モデルスペック
│   ├── user_spec.rb
│   └── book_spec.rb
├── requests/                 # リクエストスペック
│   ├── books_spec.rb
│   └── calendar_spec.rb
├── services/                 # サービススペック
│   ├── google_calendar_service_spec.rb
│   └── daily_quota_calculator_service_spec.rb
└── system/                   # システムスペック（E2E）
    └── books_spec.rb
```

### テストファイル例

#### `spec/models/book_spec.rb`

```ruby
require 'rails_helper'

RSpec.describe Book, type: :model do
  describe 'バリデーション' do
    it { should validate_presence_of(:title) }
    it { should validate_numericality_of(:total_pages).is_greater_than(0) }
  end

  describe '#calculate_daily_quota' do
    context '期限が3日後、残り181ページの場合' do
      let(:book) { build(:book, target_pages: 300, current_page: 119, deadline: 3.days.from_now.to_date) }

      it '46ページを返す' do
        expect(book.calculate_daily_quota).to eq(46)
      end
    end
  end
end
```

#### `spec/factories/books.rb`

```ruby
FactoryBot.define do
  factory :book do
    association :user
    title { 'リーダブルコード' }
    author { 'Dustin Boswell' }
    total_pages { 260 }
    target_pages { 260 }
    current_page { 0 }
    deadline { 7.days.from_now.to_date }
    status { :unread }
  end
end
```

---

## `lib/` - 共通ライブラリ

```
lib/
├── tasks/                    # Rake tasks
│   ├── daily_quota.rake      # ノルマ再計算タスク
│   └── notification.rake     # 通知送信タスク
└── modules/                  # 再利用可能モジュール
    └── date_calculator.rb    # 日付計算ヘルパー
```

### Rake task例

#### `lib/tasks/daily_quota.rake`

```ruby
namespace :daily do
  desc 'ノルマを再計算'
  task recalculate_quota: :environment do
    DailyQuotaCalculatorService.recalculate_all
    puts "#{Time.current}: ノルマを再計算しました"
  end
end
```

---

## `public/` - 静的ファイル

```
public/
├── 404.html                  # 404エラーページ
├── 422.html                  # 422エラーページ
├── 500.html                  # 500エラーページ
├── favicon.ico               # ファビコン
└── robots.txt                # クローラー制御
```

---

## ルートディレクトリ

### `.gitignore`

```
# Rails
/log/*
/tmp/*
/storage/*
!/log/.keep
!/tmp/.keep
!/storage/.keep

# Ignore master key for decrypting credentials
/config/master.key

# Ignore bundler config
/.bundle

# Ignore environment variables
.env
.env.local

# RSpec
/coverage/

# OS
.DS_Store
```

### `.env.example`

現場開発者がリポジトリからクローン後に参照する環境変数のテンプレート。
実際の値は記載せず、`.env`にコピーして各自の値を設定する。`.env`は`.gitignore`に追加済み。

```bash
# .env.example

# データベース
# Neonの接続文字列（開発環境ではローカルPostgreSQLも可）
DATABASE_URL=postgres://USER:PASSWORD@HOST/DATABASE

# メール送信（本リリースで使用、MVPでは不要）
SENDGRID_API_KEY=SG.xxxxxxxxxxxxxxxxxxxxx

# Google OAuth（本リリースで使用、MVPでは不要）
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=

# Rails
# rails credentials:editで管理する場合は不要
SECRET_KEY_BASE=
```

### `.rubocop.yml`

```yaml
AllCops:
  NewCops: enable
  TargetRubyVersion: 3.2
  Exclude:
    - 'db/**/*'
    - 'config/**/*'
    - 'bin/**/*'
    - 'vendor/**/*'

Style/Documentation:
  Enabled: false

Metrics/MethodLength:
  Max: 15

Metrics/BlockLength:
  Exclude:
    - 'spec/**/*'
    - 'config/routes.rb'
```

### `Gemfile`

```ruby
source 'https://rubygems.org'

ruby '3.2.0'

gem 'rails', '~> 7.2.0'
gem 'pg', '~> 1.5'
gem 'puma', '~> 6.0'
gem 'devise', '~> 4.9'

# 本リリースで追加
gem 'omniauth-google-oauth2'  # Google OAuth
gem 'google-api-client'       # Google Calendar API

group :development, :test do
  gem 'rspec-rails', '~> 6.0'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'pry-rails'
  gem 'rubocop-rails-omakase', require: false  # Rails 公式推奨設定
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webdrivers'
  gem 'shoulda-matchers'
end
```

### 依存関係ルール

- `app/controllers/` はHTTP入出力と認可に集中し、複雑な業務ロジックは `app/services/` または `app/models/` に委譲する
- `app/models/` は永続化とドメインロジックを担い、外部API呼び出しを直接持たない
- `app/services/` は複数モデルにまたがる処理や外部サービス連携を担当する
- `spec/` は本体コードと同じ責務単位で配置し、`support/` に共通ヘルパーを集約する

### スケーリング方針

- MVPではRailsモノリス構成を維持し、責務をディレクトリ単位で整理して変更容易性を優先する
- 定期処理が増えた場合は `lib/tasks/` からジョブキューへ移行し、非同期処理を分離する
- 一覧表示やタイムラインで負荷が高まった場合は、インデックス追加とフラグメントキャッシュを優先する
- 外部連携が増えた場合は `app/services/` を境界にしてインターフェースを明確化し、段階的な分割に備える

### `Procfile` (Render用)

```
web: bundle exec puma -C config/puma.rb
release: bundle exec rake db:migrate
```

### `README.md`

```markdown
# Yomikiri（ヨミキリ）

積読（つんどく）本に賞味期限を設定し、1日あたりのノルマを自動計算する読書管理アプリ

## セットアップ

```bash
bundle install
rails db:create db:migrate
rails s
```

## テスト

```bash
bundle exec rspec
```

## デプロイ

`main`ブランチへプッシュするとRenderに自動デプロイ
```

---

## まとめ

このリポジトリ構造は、以下の原則に基づいて設計されています:

1. **Rails標準**: `app/`, `config/`, `db/`など、Railsの慣習に従う
2. **責務分離**: モデル（ビジネスロジック）、サービス（複雑な処理）、コントローラー（HTTP処理）を明確に分離
3. **テスタビリティ**: `spec/`以下にモデル・リクエスト・システムテストを配置
4. **ドキュメント中心**: `docs/`に永続的ドキュメント、`.steering/`に作業単位のドキュメント
5. **スペック駆動開発**: `.github/`にプロンプト・スキル・エージェントを配置し、AI駆動開発をサポート

この構造により、新しい機能の追加や保守が容易になり、
チームメンバー（またはAIエージェント）がプロジェクトを理解しやすくなります。
