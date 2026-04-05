# 設計書: E2Eテスト（システムスペック）の導入

## アーキテクチャ概要

RSpec + Capybara + Selenium（headless Chrome）によるシステムスペック構成。

```
spec/
├── rails_helper.rb           # Capybara設定を追加
├── support/
│   └── capybara.rb           # ドライバ設定・ヘルパー
└── system/
    ├── auth/
    │   ├── sign_up_spec.rb   # 新規登録フロー
    │   └── sign_in_spec.rb   # ログイン・ログアウトフロー
    └── books/
        ├── books_crud_spec.rb       # 書籍CRUD（登録・一覧・詳細・削除）
        ├── progress_update_spec.rb  # 進捗更新（±ボタン・直接入力トグル）
        ├── complete_spec.rb         # 読了フロー・お祝いモーダル
        └── deadline_spec.rb         # 期限延長モーダル
```

## コンポーネント設計

### 1. Capybara 設定（spec/support/capybara.rb）

**責務**:
- デフォルトドライバ（JS不要 → rack_test）の設定
- JS対応ドライバ（selenium_chrome_headless）の登録
- CI環境のサンドボックス対応オプション付与

**実装の要点**:

```ruby
# spec/support/capybara.rb
RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, type: :system, js: true) do
    driven_by :selenium, using: :headless_chrome, screen_size: [1400, 900]
  end
end

Capybara.configure do |config|
  config.default_max_wait_time = 5
  config.server = :puma, { Silent: true }
end
```

**CI環境でのheadless Chrome設定（selenium Options）**:

```ruby
options = Selenium::WebDriver::Chrome::Options.new
options.add_argument('--headless')
options.add_argument('--no-sandbox')
options.add_argument('--disable-dev-shm-usage')
options.add_argument('--disable-gpu')

Capybara.register_driver :headless_chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end
```

### 2. rails_helper.rb への追加設定

**追加内容**:

```ruby
# rails_helper.rb に追加
require 'capybara/rspec'
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }
```

**注意点（DatabaseCleaner 不要の理由）**:

`use_transactional_fixtures = true` のままでは、Seleniumドライバを使うシステムスペック（別プロセス）でトランザクションが別のコネクションになり、テストデータが見えない。

しかし RSpec-Rails + Capybara の組み合わせでは、`:rack_test` ドライバなら `use_transactional_fixtures = true` のままで動作する。

Selenium（JS）を使うスペックでは `DatabaseCleaner` が必要。対応策:

**オプションA: DatabaseCleaner gem を追加する（推奨）**

```ruby
# Gemfile test group
gem "database_cleaner-active_record"
```

```ruby
# spec/support/database_cleaner.rb
RSpec.configure do |config|
  config.before(:suite) { DatabaseCleaner.strategy = :transaction }

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
  end

  config.after(:each, js: true) { DatabaseCleaner.clean }

  config.around(:each) do |example|
    DatabaseCleaner.cleaning { example.run }
  end
end
```

**オプションB: RSpec-Rails の built-in 方法を使う（シンプル）**

```ruby
# system spec ファイル内で個別に対処
RSpec.describe 'Book creation', type: :system, js: true do
  # Capybara が自動で truncation に切り替える設定を使用
end
```

→ **オプションA（DatabaseCleaner）を採用する**。明示的で確実。

### 3. システムスペック: 認証フロー

#### spec/system/auth/sign_up_spec.rb

```ruby
RSpec.describe '新規登録', type: :system do
  it 'メールアドレスとパスワードで新規登録できる' do
    visit new_user_registration_path
    fill_in 'メールアドレス', with: 'test@example.com'
    fill_in 'パスワード', with: 'password123'
    fill_in 'パスワード（確認）', with: 'password123'
    click_button '新規登録する'
    expect(page).to have_current_path(books_path)
  end
end
```

#### spec/system/auth/sign_in_spec.rb

```ruby
RSpec.describe 'ログイン・ログアウト', type: :system do
  let!(:user) { create(:user, password: 'password123') }

  it 'ログインできる' do
    visit new_user_session_path
    fill_in 'メールアドレス', with: user.email
    fill_in 'パスワード', with: 'password123'
    click_button 'ログインする'
    expect(page).to have_current_path(books_path)
  end

  it 'ドロップダウンからログアウトできる', js: true do
    sign_in user
    visit root_path
    # ドロップダウンクリック
    find('[data-controller="dropdown"]').click
    click_link 'ログアウト'
    expect(page).to have_current_path(root_path)
  end
end
```

### 4. システムスペック: 書籍CRUD

#### spec/system/books/books_crud_spec.rb

**書籍登録**:
- フォームに入力してsubmit
- 詳細画面にリダイレクト・タイトルが表示されることを確認

**削除確認モーダル（JS必要）**:
```ruby
it '削除確認モーダルが開閉する', js: true do
  book = create(:book, user: user)
  visit book_path(book)
  click_button '削除する'            # モーダルを開く
  expect(page).to have_text('本当に削除しますか')
  click_button 'キャンセル'          # モーダルを閉じる
  expect(page).not_to have_text('本当に削除しますか')
  # 削除実行
  click_button '削除する'
  click_button '削除する'            # モーダル内の確認
  expect(page).to have_current_path(books_path)
  expect(page).not_to have_text(book.title)
end
```

### 5. システムスペック: 進捗更新（JS必須）

#### spec/system/books/progress_update_spec.rb

```ruby
RSpec.describe '進捗更新', type: :system, js: true do
  # ±ボタン動作
  it '＋ボタンでpages_readが増加する' do
    # ...
  end

  # 詳細入力トグル
  it '「現在ページを直接入力」を押すと折りたたみが展開する' do
    visit book_path(book)
    expect(page).not_to have_field('direct_page')  # 初期は非表示
    click_button '現在ページを直接入力'
    expect(page).to have_field('direct_page')      # 展開後は表示
  end
end
```

### 6. システムスペック: 読了フロー（JS必須）

#### spec/system/books/complete_spec.rb

```ruby
it '読了ボタンでお祝いモーダルが表示される', js: true do
  book = create(:book, user: user, current_page: 100, target_pages: 100, status: :reading)
  visit book_path(book)
  click_button '読了にする！'
  # お祝いモーダル表示確認
  expect(page).to have_text('読了おめでとうございます')
  expect(page).to have_text(book.title)
  click_link '一覧に戻る'
  expect(page).to have_current_path(books_path)
end
```

### 7. システムスペック: 期限延長（JS必須）

#### spec/system/books/deadline_spec.rb

```ruby
it '期限延長モーダルが開閉する', js: true do
  book = create(:book, user: user, deadline: Date.current + 7)
  visit book_path(book)
  click_button '期限を延長する'
  expect(page).to have_css('[data-target="modal.extendOverlay"]', visible: true)
  # 新しい期限を選択・延長
  fill_in 'deadline', with: (Date.current + 14).to_s
  click_button '延長する'
  expect(page).to have_text('読了期限を延長しました')
  expect(book.reload.deadline).to eq(Date.current + 14)
end
```

## データフロー

### システムスペック実行時の流れ

```
1. RSpec が before(:suite) でDBをクリーン状態に
2. FactoryBot でテストデータ作成
3. Capybara がブラウザ（headless Chrome or rack_test）を起動
4. Capybara がアクションを実行（visit, click, fill_in等）
5. Stimulus JS が動作（js: true の場合）
6. expect(page) でDOM/テキストを検証
7. after(:each) でDBをクリーン（DatabaseCleaner）
```

## エラーハンドリング戦略

### JS待機タイムアウト

Capybara の `default_max_wait_time = 5` でリトライ。  
非同期操作後は `expect(page).to have_text(...)` で暗黙的な待機を活用する。

### CI環境でのChrome不在

`selenium-webdriver` は Chrome Webdriver を自動管理するため、  
Dockerfile/CI 環境に `google-chrome-stable` が必要。

## テスト戦略

### ドライバ使い分けポリシー

| テスト種別 | ドライバ | 理由 |
|-----------|---------|------|
| フォーム・ページ遷移（JS不要） | rack_test | 高速 |
| モーダル・ボタン・トグル（JS要） | selenium_chrome_headless | 実際のJS動作確認 |

### テストデータ

- FactoryBot + Devise の `sign_in` ヘルパーを使用
- Capybara DSL でのログインは `visit`+`fill_in`+`click_button` で実際のフォームを使う

## 依存ライブラリ

```ruby
# Gemfile (test group に追加)
gem "database_cleaner-active_record"
```

## ディレクトリ構造

```
spec/
├── rails_helper.rb                 ← 変更: Capybara設定を追加
├── support/
│   ├── capybara.rb                 ← 新規作成
│   └── database_cleaner.rb         ← 新規作成
└── system/
    ├── auth/
    │   ├── sign_up_spec.rb         ← 新規作成
    │   └── sign_in_spec.rb         ← 新規作成
    └── books/
        ├── books_crud_spec.rb      ← 新規作成
        ├── progress_update_spec.rb ← 新規作成
        ├── complete_spec.rb        ← 新規作成
        └── deadline_spec.rb        ← 新規作成
```

## 実装の順序

1. Gemfile に `database_cleaner-active_record` を追加 → `bundle install`
2. `spec/support/capybara.rb` を作成（ドライバ設定）
3. `spec/support/database_cleaner.rb` を作成（DBクリーン設定）
4. `rails_helper.rb` に `require 'capybara/rspec'` と support 読み込みを追加
5. `spec/system/auth/` のスペックを作成（JS不要で動作確認）
6. `spec/system/books/books_crud_spec.rb` を作成
7. `spec/system/books/progress_update_spec.rb`（JS必要）を作成
8. `spec/system/books/complete_spec.rb`（JS必要）を作成
9. `spec/system/books/deadline_spec.rb`（JS必要）を作成
10. `bundle exec rspec spec/system/` で全体テスト実行確認

## 既存テストへの影響

- `rails_helper.rb` への追加は後方互換性あり（既存スペックに影響なし）
- `use_transactional_fixtures = true` は `rack_test` スペックには維持される
- DatabaseCleaner は `js: true` タグがついたスペックのみに適用
