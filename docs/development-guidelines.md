# 開発ガイドライン (Development Guidelines)

## コーディング規約

### Ruby / Rails スタイルガイド

**基本方針**: [The Ruby Style Guide](https://rubystyle.guide/)および[The Rails Style Guide](https://rails.rubystyle.guide/)に準拠し、RuboCopで自動チェックを行います。

#### インデント・フォーマット

```ruby
# ✅ Good: 2スペースインデント
class Book < ApplicationRecord
  def calculate_daily_quota
    remaining_pages = target_pages - current_page
    remaining_days = days_until_deadline
    (remaining_pages.to_f / remaining_days).ceil
  end
end

# ❌ Bad: タブやインデントなし
class Book < ApplicationRecord
def calculate_daily_quota
remaining_pages=target_pages-current_page
remaining_days=days_until_deadline
(remaining_pages.to_f/remaining_days).ceil
end
end
```

#### 命名規則

| 種類 | 規則 | 例 |
|------|------|-----|
| クラス・モジュール | UpperCamelCase | `Book`, `GoogleCalendarService` |
| メソッド・変数 | snake_case | `calculate_daily_quota`, `remaining_pages` |
| 定数 | SCREAMING_SNAKE_CASE | `MAX_DEADLINE_DAYS` |
| ファイル名 | snake_case | `google_calendar_service.rb` |

```ruby
# ✅ Good
class DailyQuotaCalculatorService
  MAX_PAGES_PER_DAY = 100

  def recalculate_all
    active_books = Book.active
    active_books.each { |book| book.update_quota }
  end
end

# ❌ Bad
class dailyQuotaCalculator
  maxPagesPerDay = 100

  def RecalculateAll
    ActiveBooks = Book.active
    ActiveBooks.each { |book| book.UpdateQuota }
  end
end
```

#### 文字列リテラル

```ruby
# ✅ Good: シングルクォートを基本とし、式展開が必要な時のみダブルクォート
title = 'リーダブルコード'
message = "#{title}を読む"

# ❌ Bad: 不要なダブルクォート
title = "リーダブルコード"
```

#### ハッシュ記法

```ruby
# ✅ Good: Ruby 1.9以降のシンボルキー記法
params = { title: 'リーダブルコード', total_pages: 260 }

# ❌ Bad: 古いハッシュロケット記法
params = { :title => 'リーダブルコード', :total_pages => 260 }
```

#### メソッド定義

```ruby
# ✅ Good: 短いメソッド（10-15行以内）、1つの責務
def calculate_daily_quota
  remaining_pages = target_pages - current_page
  remaining_days = days_until_deadline
  return 0 if remaining_days <= 0 || remaining_pages <= 0
  (remaining_pages.to_f / remaining_days).ceil
end

# ❌ Bad: 長いメソッド、複数の責務
def process_book
  # バリデーション
  # 計算
  # データベース更新
  # メール送信
  # ...50行
end
```

#### ガード節の活用

```ruby
# ✅ Good: 早期リターンで正常系を浮き立たせる
def calculate_daily_quota
  return 0 if deadline.nil?
  return 0 if target_pages <= current_page

  remaining_pages = target_pages - current_page
  remaining_days = days_until_deadline
  (remaining_pages.to_f / remaining_days).ceil
end

# ❌ Bad: ネストが深い
def calculate_daily_quota
  if !deadline.nil?
    if target_pages > current_page
      remaining_pages = target_pages - current_page
      remaining_days = days_until_deadline
      (remaining_pages.to_f / remaining_days).ceil
    else
      0
    end
  else
    0
  end
end
```

---

### HTML / ERB スタイル

```erb
<!-- ✅ Good: 自動エスケープを使用 -->
<h1><%= @book.title %></h1>
<p><%= @book.author %></p>

<!-- ❌ Bad: 手動エスケープは不要 -->
<h1><%= h(@book.title) %></h1>

<!-- ✅ Good: パーシャルの活用 -->
<%= render 'form', book: @book %>

<!-- ✅ Good: ヘルパーメソッドの活用 -->
<%= link_to '編集', edit_book_path(@book), class: 'btn btn-primary' %>

<!-- ❌ Bad: 生のHTMLを直書き -->
<a href="/books/<%= @book.id %>/edit" class="btn btn-primary">編集</a>
```

---

### JavaScript / Stimulus スタイル

```javascript
// ✅ Good: Stimulus controller にUIの責務を閉じ込める
import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['input']

  increment() {
    this.inputTarget.value = Number(this.inputTarget.value || 0) + 1
  }
}

// ❌ Bad: グローバル関数でDOMを直接操作する
function incrementPage() {
  document.getElementById('pages-read').value++
}
```

- 小さなUI操作は Stimulus を優先し、jQuery のようなグローバル操作は避ける
- サーバー状態の変更は Turbo / Rails のフォーム送信を基本とし、手書きAJAXを増やしすぎない
- HTML側の識別子は `page-counter` のような `kebab-case`、ファイル名は `page_counter_controller.js` の形式に統一する

---

### CSS スタイル

```css
/* ✅ Good: BEM記法（Block Element Modifier） */
.book-card { }
.book-card__title { }
.book-card__author { }
.book-card--urgent { }

/* ❌ Bad: 深いネスト、曖昧なクラス名 */
.card .title .text { }
.urgent { }
```

- ベースはシンプルなコンポーネント指向CSSとし、命名はBEMを採用する
- 本プロジェクトではTailwindは使用せず、BEMのみを採用する（`architecture.md` 参照）
- 1画面内でクラスを無秩序に混在させず、主要パターンをコンポーネント単位で統一する

---

## テスト規約

### テスト戦略

```
        /\
       /E2\     ← System Specs（数件）: ユーザーフロー全体
      /────\
     /  統合 \   ← Request Specs（主要フロー）: コントローラー
    /────────\
   /    単体   \  ← Model Specs（全ロジック）: ビジネスロジック
  /────────────\
```

#### カバレッジ目標

| テスト種別 | カバレッジ目標 | 優先度 |
|-----------|--------------|--------|
| Model Specs | 90%以上 | 最優先（全ビジネスロジックをカバー） |
| Request Specs | 主要フローのみ | 高（CRUD, 進捗更新, 認証） |
| System Specs | 3-5ケース | 中（重要なユースケースのみ） |

#### カバレッジ計測

```ruby
# Gemfile
group :test do
  gem 'simplecov', require: false
end

# spec/spec_helper.rb
require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/spec/'
  minimum_coverage 80  # CI 強制最低ライン（Model Specs の推奨目標は 90%以上）
end
```

- CIではカバレッジ低下を確認できるよう `coverage/` を成果物として扱う
- 数値のみを追わず、`Book` とサービス層の重要ロジックを優先して埋める

### モデルスペック（Model Specs）

**対象**: ビジネスロジック、バリデーション、スコープ、関連

```ruby
# spec/models/book_spec.rb
require 'rails_helper'

RSpec.describe Book, type: :model do
  # 関連
  describe '関連' do
    it { should belong_to(:user) }
    it { should have_many(:reading_logs).dependent(:destroy) }
  end

  # バリデーション
  describe 'バリデーション' do
    it { should validate_presence_of(:title) }
    it { should validate_numericality_of(:total_pages).is_greater_than(0) }
    it { should validate_numericality_of(:target_pages).is_greater_than(0) }
    it { should validate_numericality_of(:current_page).is_greater_than_or_equal_to(0) }
  end

  # カスタムバリデーション
  describe '#deadline_cannot_be_in_the_past' do
    context '期限が過去の場合' do
      let(:book) { build(:book, deadline: 1.day.ago.to_date) }

      it '無効である' do
        expect(book).to be_invalid
        expect(book.errors[:deadline]).to include('は過去の日付にできません')
      end
    end

    context '期限が未来の場合' do
      let(:book) { build(:book, deadline: 1.day.from_now.to_date) }

      it '有効である' do
        expect(book).to be_valid
      end
    end
  end

  # スコープ
  describe 'スコープ' do
    describe '.active' do
      let!(:unread_book) { create(:book, status: :unread) }
      let!(:reading_book) { create(:book, status: :reading) }
      let!(:completed_book) { create(:book, status: :completed) }

      it '未読と読書中の本のみを返す' do
        expect(Book.active).to contain_exactly(unread_book, reading_book)
      end
    end
  end

  # ビジネスロジック
  describe '#calculate_daily_quota' do
    context '期限が3日後、残り181ページの場合' do
      let(:book) { build(:book, target_pages: 300, current_page: 119, deadline: 3.days.from_now.to_date) }

      it '46ページを返す（⌈181 / 4⌉）' do
        expect(book.calculate_daily_quota).to eq(46)
      end
    end

    context '残ページが0の場合' do
      let(:book) { build(:book, target_pages: 300, current_page: 300, deadline: 3.days.from_now.to_date) }

      it '0を返す' do
        expect(book.calculate_daily_quota).to eq(0)
      end
    end

    context '期限が過去の場合' do
      let(:book) { build(:book, deadline: 1.day.ago.to_date) }

      it '0を返す' do
        expect(book.calculate_daily_quota).to eq(0)
      end
    end
  end
end
```

### リクエストスペック（Request Specs）

**対象**: コントローラーのアクション、HTTPレスポンス、認証

```ruby
# spec/requests/books_spec.rb
require 'rails_helper'

RSpec.describe 'Books', type: :request do
  let(:user) { create(:user) }
  let(:book) { create(:book, user: user) }

  describe 'GET /books' do
    context 'ログインしている場合' do
      before { sign_in user }

      it '200を返す' do
        get books_path
        expect(response).to have_http_status(:ok)
      end

      it '自分の本のみを表示する' do
        other_user_book = create(:book)
        get books_path
        expect(response.body).to include(book.title)
        expect(response.body).not_to include(other_user_book.title)
      end
    end

    context 'ログインしていない場合' do
      it 'ログイン画面にリダイレクトする' do
        get books_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'POST /books' do
    before { sign_in user }

    context '有効なパラメータの場合' do
      let(:valid_params) do
        {
          book: {
            title: 'リーダブルコード',
            total_pages: 260,
            target_pages: 260,
            deadline: 7.days.from_now.to_date
          }
        }
      end

      it '本が作成される' do
        expect {
          post books_path, params: valid_params
        }.to change(Book, :count).by(1)
      end

      it '一覧画面にリダイレクトする' do
        post books_path, params: valid_params
        expect(response).to redirect_to(books_path)
      end
    end

    context '無効なパラメータの場合' do
      let(:invalid_params) do
        { book: { title: '' } }
      end

      it '本が作成されない' do
        expect {
          post books_path, params: invalid_params
        }.not_to change(Book, :count)
      end

      it '422を返す' do
        post books_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH /books/:id/update_progress' do
    before { sign_in user }

    context '有効なパラメータの場合' do
      it '現在ページが更新される' do
        expect {
          patch update_progress_book_path(book), params: { pages_read: 10 }
          book.reload
        }.to change(book, :current_page).by(10)
      end
    end
  end
end
```

### システムスペック（System Specs）

**対象**: ユーザーの操作フロー全体（E2E）

```ruby
# spec/system/books_spec.rb
require 'rails_helper'

RSpec.describe 'Books', type: :system do
  let(:user) { create(:user) }

  before do
    driven_by(:selenium_chrome_headless)
    sign_in user
  end

  describe '本の登録' do
    it 'ユーザーは本を登録できる' do
      visit root_path
      click_link '本を登録'

      fill_in 'タイトル', with: 'リーダブルコード'
      fill_in '著者', with: 'Dustin Boswell'
      fill_in '総ページ数', with: '260'
      fill_in '読了対象ページ数', with: '260'
      fill_in '読了期限', with: 7.days.from_now.to_date
      click_button '登録する'

      expect(page).to have_content('本を登録しました')
      expect(page).to have_content('リーダブルコード')
    end
  end

  describe '進捗更新' do
    let!(:book) { create(:book, user: user, current_page: 100) }

    it 'ユーザーは進捗を更新できる' do
      visit book_path(book)

      fill_in '今日読んだページ数', with: '10'
      click_button '更新する'

      expect(page).to have_content('進捗を更新しました')
      expect(page).to have_content('110 / 260ページ')
    end
  end
end
```

### テストデータ（FactoryBot）

```ruby
# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    password_confirmation { 'password123' }
  end
end

# spec/factories/books.rb
FactoryBot.define do
  factory :book do
    association :user
    sequence(:title) { |n| "Book Title #{n}" }
    author { 'Test Author' }
    total_pages { 260 }
    target_pages { 260 }
    current_page { 0 }
    deadline { 7.days.from_now.to_date }
    status { :unread }

    trait :reading do
      status { :reading }
      current_page { 100 }
    end

    trait :completed do
      status { :completed }
      current_page { 260 }
    end

    trait :urgent do
      deadline { 1.day.from_now.to_date }
    end
  end
end
```

---

## Git ワークフロー

### ブランチ戦略（GitHub Flow）

```
main ← 本番環境（常にデプロイ可能）
 ├─ feature/#12-add-google-calendar
 ├─ feature/#8-implement-quota-calculator
 └─ fix/#14-book-validation-error
```

#### ブランチ命名規則

> 詳細は [docs/development-workflow.md](development-workflow.md) を参照してください。

```
feature/#{Issue番号}-{機能の短い説明}

例:
  feature/#1-rails-setup
  feature/#12-add-google-calendar
  feature/#8-implement-quota-calculator
  fix/#14-book-validation-error
```

**規則**: Issue 番号を必ずブランチ名に含めてください。

| 種類 | プレフィックス | 例 |
|------|--------------|-----|
| 新機能 | `feature/` | `feature/#12-add-google-calendar` |
| バグ修正 | `fix/` | `fix/#14-book-validation-error` |
| リファクタリング | `refactor/` | `refactor/#20-extract-service-object` |
| ドキュメント | `docs/` | `docs/#3-update-readme` |

### コミット規約

#### `.rubocop.yml` の基本方針

```yaml
AllCops:
  NewCops: enable
  TargetRubyVersion: 3.2

Metrics/MethodLength:
  Max: 15

Style/Documentation:
  Enabled: false
```

- まずは `rubocop-rails-omakase` 相当の穏当な設定を基準にし、プロジェクト事情で必要な差分のみ追加する
- `db/`, `bin/`, `vendor/` など自動生成物への過剰な警告は除外する

#### コミットメッセージフォーマット

> 詳細は [docs/development-workflow.md](development-workflow.md) を参照してください。

```
{type}: {内容} (#{Issue番号})

例:
  feat: Devise による User モデル作成 (#4)
  fix: ノルマ計算で期限当日が D=0 になるバグを修正 (#14)
  test: Book モデルのバリデーションテストを追加 (#9)
```

**規則**: Issue 番号を末尾に `(#番号)` 形式で必ず含めてください。

#### コミット種別

| 種別 | 説明 | 例 |
|------|------|-----|
| feat | 新機能 | `feat: Googleカレンダー連携機能を追加` |
| fix | バグ修正 | `fix: ノルマ計算の切り上げロジックを修正` |
| refactor | リファクタリング | `refactor: DailyQuotaCalculatorをサービスに抽出` |
| test | テスト追加・修正 | `test: Book#calculate_daily_quotaのスペックを追加` |
| docs | ドキュメント | `docs: READMEにセットアップ手順を追加` |
| style | コードスタイル | `style: RuboCop違反を修正` |
| chore | その他 | `chore: Gemfile更新` |

#### コミット例

```bash
git commit -m "feat: 進捗更新機能を実装 (#45)"

# または複数のポイントを伝えたい場合（1行目に必ずIssue番号を含める）
git commit -m "feat: BooksController に進捗更新アクションを追加 (#45)"
```

### Pull Request プロセス

#### 1. ブランチ作成

```bash
git switch main
git pull origin main
git switch -c feature/#12-add-google-calendar
```

#### 2. 実装・コミット

```bash
# 実装
git add app/services/google_calendar_service.rb
git commit -m "feat: GoogleCalendarService を実装 (#12)"

# テスト
bundle exec rspec

# Lint
bundle exec rubocop
```

#### 3. プッシュ

```bash
git push origin feature/#12-add-google-calendar
```

#### 4. Pull Request作成

**PRテンプレート**:

```markdown
## 概要
Googleカレンダー連携機能（簡易版）を実装しました。

## 変更内容
- [ ] GoogleCalendarServiceを追加
- [ ] CalendarControllerを追加
- [ ] 一覧画面に「Googleカレンダーに追加」リンクを追加
- [ ] スペックを追加

## テスト
- [ ] Model Specs: GoogleCalendarService
- [ ] Request Specs: CalendarController
- [ ] System Specs: 手動テスト（カレンダー画面が開くことを確認）

## スクリーンショット
（画面がある場合）

## 関連Issue
Closes #123

## レビュー観点
- URL生成ロジックが正しいか
- セキュリティ上の問題がないか
```

#### 5. コードレビュー

**レビュー基準**:
- [ ] テストが通っているか（GitHub Actions）
- [ ] RuboCop違反がないか
- [ ] ビジネスロジックが正しいか
- [ ] セキュリティ上の問題がないか
- [ ] パフォーマンスに問題がないか

**レビューコメント例**:
```
✅ LGTM (Looks Good To Me)
💬 質問: このロジックは〇〇の場合にどう動作しますか？
🚨 問題: XSS脆弱性の可能性があります
💡 提案: このメソッドはサービスに抽出したほうが良いかもしれません
```

#### 6. マージ

**マージ方法**: Squash and Merge（複数コミットを1つにまとめる）

**マージ条件**:
- [ ] CIがすべて成功している
- [ ] 少なくとも1回はセルフレビュー済みである
- [ ] 仕様変更があれば関連ドキュメントが更新されている
- [ ] 重大な未解決レビューコメントが残っていない

```bash
git switch main
git pull origin main
git branch -d feature/#12-add-google-calendar  # ローカルブランチ削除
```

---

## CI/CD フロー

### GitHub Actions

> CI パイプラインの完全な定義と CD（Render 自動デプロイ）の設定は [docs/development-workflow.md](development-workflow.md) を参照してください。

#### `.github/workflows/ci.yml`（概要）

PR 作成時に以下の 2 ジョブが自動実行されます。**すべて GREEN にならないとマージ不可**です。

```yaml
name: CI

on:
  pull_request:
    branches: [main]

jobs:
  # ① 静的解析・セキュリティスキャン (RuboCop / Brakeman / bundler-audit)
  lint-security:
    name: RuboCop & Brakeman & bundler-audit
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: .ruby-version   # .ruby-version ファイルで管理
          bundler-cache: true
      - run: bundle exec rubocop --format github
      - run: bundle exec brakeman --no-pager --format github
      - run: |
          gem install bundler-audit --no-document
          bundle-audit check --update

  # ② 自動テスト (RSpec)
  test:
    name: RSpec
    runs-on: ubuntu-latest
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
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: .ruby-version
          bundler-cache: true
      - run: |
          bundle exec rails db:create
          bundle exec rails db:schema:load
      - run: bundle exec rspec --format progress
```

#### `.github/workflows/daily_tasks.yml`

```yaml
name: Daily Tasks

on:
  schedule:
    - cron: '0 15 * * *'  # 毎日JST 00:00 (UTC 15:00)
  workflow_dispatch:  # 手動実行も可能

jobs:
  recalculate:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: .ruby-version   # .ruby-version ファイルで管理
          bundler-cache: true

      - name: Run Daily Quota Recalculation
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
          RAILS_ENV: production
        run: bundle exec rake daily:recalculate_quota

      - name: Send Notifications
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
          SENDGRID_API_KEY: ${{ secrets.SENDGRID_API_KEY }}
          RAILS_ENV: production
        run: bundle exec rake notification:send_reminders
```

---

## セキュリティガイドライン

### 機密情報管理

**環境変数で管理（`.env`は`.gitignore`）**:

```ruby
# config/initializers/sendgrid.rb
ActionMailer::Base.smtp_settings = {
  user_name: 'apikey',
  password: ENV['SENDGRID_API_KEY'],
  domain: 'yomikiri.com',
  address: 'smtp.sendgrid.net',
  port: 587,
  authentication: :plain,
  enable_starttls_auto: true
}
```

**Render環境変数設定**:
- ダッシュボード > Environment > Environment Variables
- `SENDGRID_API_KEY`, `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`

### 入力検証

```ruby
# ✅ Good: Strong Parameters（:status は含めない—専用の complete アクションのみで変更）
def book_params
  params.require(:book).permit(
    :title, :author, :total_pages, :target_pages,
    :current_page, :deadline, :cover_image_url
  )
end

# ✅ Good: バリデーション
validates :title, presence: true, length: { maximum: 255 }
validates :total_pages, numericality: { only_integer: true, greater_than: 0 }
```

### CSRF対策

```erb
<!-- ✅ Good: form_withは自動的にトークンを埋め込む -->
<%= form_with model: @book do |f| %>
  <%= f.text_field :title %>
  <%= f.submit '登録' %>
<% end %>
```

### XSS対策

```erb
<!-- ✅ Good: 自動エスケープ -->
<h1><%= @book.title %></h1>

<!-- ⚠️ 注意: HTMLを出力する場合はサニタイズ -->
<div><%= sanitize(@book.description) %></div>
```

---

## パフォーマンスガイドライン

### N+1クエリの回避

```ruby
# ❌ Bad: N+1問題
@books = current_user.books
@books.each { |book| book.reading_logs.count }

# ✅ Good: includes で一括取得
@books = current_user.books.includes(:reading_logs)
@books.each { |book| book.reading_logs.count }
```

### インデックスの設定

```ruby
# db/migrate/xxx_add_indexes.rb
add_index :books, :user_id
add_index :books, :deadline
add_index :books, [:user_id, :status]  # 複合インデックス
```

### ページネーション

```ruby
# Gemfile
gem 'kaminari'

# Controller
@books = current_user.books.page(params[:page]).per(50)

# View
<%= paginate @books %>
```

---

## ドキュメント規約

### コード内ドキュメント

```ruby
# 複雑なロジックにはコメントを記述
# ノルマ計算: ⌈残ページ / 残日数⌉
# 例: 181ページ残り、4日間 → ⌈181/4⌉ = 46ページ/日
def calculate_daily_quota
  remaining_pages = target_pages - current_page
  remaining_days = days_until_deadline
  return 0 if remaining_pages <= 0 || remaining_days <= 0
  (remaining_pages.to_f / remaining_days).ceil
end
```

### README更新

**新機能追加時はREADME更新**:
```markdown
## 機能
- 本の登録・編集・削除
- 進捗更新（今日読んだページ数入力）
- ノルマ自動計算
- Googleカレンダー連携（簡易版）← 追加
```

---

## 環境セットアップ

### 前提条件

以下のツールをインストールしてください:

| ツール | バージョン | インストール方法 |
|-------|-----------|----------------|
| Ruby | 3.2.x | rbenv または asdf を推奨 |
| PostgreSQL | 16.x | `brew install postgresql@16` (Mac) / `apt install postgresql` (Linux) |
| Node.js | 20.x | nvm を推奨 |
| Git | 最新版 | OS標準またはhttps://git-scm.com |

### セットアップ手順

```bash
# 1. リポジトリをクローン
git clone https://github.com/[your-org]/Yomikiri.git
cd Yomikiri

# 2. Ruby バージョンを確認・インストール
ruby -v  # 3.2.x であることを確認
# rbenv の場合:
rbenv install 3.2.0
rbenv local 3.2.0

# 3. Gem をインストール
bundle install

# 4. 環境変数を設定
cp .env.example .env
# .env を編集して必要な値を設定（後述）

# 5. データベースを作成・マイグレーション
rails db:create
rails db:migrate

# 6. 初期データを投入（任意）
rails db:seed

# 7. サーバーを起動
rails server
# または
bin/dev
```

### 環境変数の設定（`.env`）

`.env.example` をコピーして `.env` を作成し、以下を設定します:

```bash
# .env（Gitにコミットしない）

# データベース接続（ローカル開発では不要な場合あり）
DATABASE_URL=postgresql://localhost/yomikiri_development

# SendGrid（本リリース以降）
SENDGRID_API_KEY=your_sendgrid_api_key

# Google OAuth（本リリース以降）
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
```

> **Note**: 本番環境の秘密情報は Render ダッシュボードの Environment Variables に設定してください。`.env` はローカル専用です。

### 動作確認

```bash
# ブラウザで確認
open http://localhost:3000

# ログイン確認（db:seedを実行した場合）
# Email: test@example.com
# Password: password123

# テスト実行
bundle exec rspec

# Lint チェック
bundle exec rubocop
```

### よくある問題とその解決法

**問題1: `bundle install` でエラーが出る**
```bash
# pg gem のビルドに失敗する場合（Mac）
gem install pg -- --with-pg-config=$(brew --prefix postgresql@16)/bin/pg_config

# または
bundle config build.pg --with-pg-config=$(brew --prefix postgresql@16)/bin/pg_config
bundle install
```

**問題2: `rails db:create` でデータベース接続エラー**
```bash
# PostgreSQL が起動しているか確認
pg_isready -h localhost
# 起動していない場合（Mac）
brew services start postgresql@16
# Linux
sudo systemctl start postgresql
```

**問題3: `ActiveRecord::PendingMigrationError`**
```bash
rails db:migrate
```

**問題4: `undefined method` エラー**
```bash
# Gemを再インストール
bundle install
# Springを再起動
spring stop
```

---

## デバッグガイドライン

### ログの確認

**開発環境**:
```bash
# リアルタイムでログを表示
tail -f log/development.log

# 特定のキーワードを含む行を抽出
grep "ActiveRecord" log/development.log

# エラーのみを抽出
grep "ERROR" log/development.log
```

**本番環境（Render）**:
- Renderダッシュボード → サービス → Logs タブでリアルタイム閲覧
- フィルタリング機能で特定のメッセージを検索

### デバッガーの使い方（pry）

```ruby
# Gemfile に既に含まれている pry-rails を使用

# コードに挿入してデバッグ
def calculate_daily_quota
  remaining_pages = target_pages - current_page
  binding.pry  # ← ここで実行が止まり、コンソールが開く
  remaining_days = days_until_deadline
  (remaining_pages.to_f / remaining_days).ceil
end
```

**pry コンソールでの操作**:
```ruby
# 変数の値を確認
remaining_pages  #=> 181

# ネストした変数も確認
self.target_pages  #=> 300
self.current_page  #=> 119

# 次の行に進む
next

# メソッドの中に入る
step

# 実行を再開
continue

# pry を終了
exit
```

### RSpec デバッグ

```bash
# 失敗したテストのみ再実行
bundle exec rspec --only-failures

# 特定のファイルのみ実行
bundle exec rspec spec/models/book_spec.rb

# 特定の行のみ実行
bundle exec rspec spec/models/book_spec.rb:45

# より詳細なエラー出力
bundle exec rspec --format documentation

# 最初の失敗で止める
bundle exec rspec --fail-fast
```

**テスト内でデバッグ**:
```ruby
it 'ノルマを計算できる' do
  book = create(:book, target_pages: 300, current_page: 119)
  puts book.inspect  # 標準出力でオブジェクトを確認
  binding.pry        # ここで止めてデバッグ
  expect(book.calculate_daily_quota).to eq(46)
end
```

### N+1クエリのデバッグ（bullet）

```ruby
# Gemfileに追加（development, test）
gem 'bullet'

# config/environments/development.rb
config.after_initialize do
  Bullet.enable = true
  Bullet.alert = true       # ブラウザにアラートを表示
  Bullet.rails_logger = true # ログにも出力
end
```

bulletが有効な状態でブラウザを操作すると、N+1が発生した場合はログと画面にアラートが出ます:
```
N+1 Query detected
  Book => [:reading_logs]
  Add to your finder: :includes => [:reading_logs]
```

### よくあるエラーと対処法

| エラー | 原因 | 対処法 |
|-------|------|--------|
| `ActiveRecord::RecordNotFound` | IDが存在しない、または他ユーザーのレコード | `current_user.books.find(id)` でスコープを限定 |
| `ActionController::ParameterMissing` | Strong Parametersのキーが異なる | `params.inspect` でパラメータを確認 |
| `NoMethodError: undefined method 'xxx'` | nil に対してメソッドを呼んだ | `&.` (safe navigation operator) を使用 |
| `ActiveRecord::InvalidForeignKey` | 関連するレコードが存在しない | `dependent: :destroy` を確認 |
| `ActionController::InvalidAuthenticityToken` | CSRFトークン不一致 | フォームに `<%= form_with %>` を使用 |

### パフォーマンスのデバッグ

```ruby
# クエリの実行時間を確認（rails console）
ActiveRecord::Base.logger = Logger.new(STDOUT)
Book.includes(:reading_logs).by_deadline.explain

# 実行計画を確認
Book.where(user: current_user).explain
```

---

## まとめ

このガイドラインは以下の原則に基づいています:

1. **一貫性**: RuboCopによる自動チェックで統一されたコード
2. **テスタビリティ**: テストピラミッドによる効率的なテスト
3. **保守性**: 明確なブランチ戦略、コミット規約
4. **セキュリティ**: 入力検証、CSRF対策、XSS対策
5. **パフォーマンス**: N+1対策、インデックス、ページネーション

新しいメンバーがプロジェクトに参加する際は、まずこのガイドラインを読んでください。
