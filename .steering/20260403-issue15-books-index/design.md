# 実装設計

## アーキテクチャ概要

Rails MVC パターンで実装。既存のコンポーネント（Devise認証、BEMスタイル命名）を踏襲。

## 変更ファイル一覧

### 新規作成
- `app/controllers/books_controller.rb` - 書籍コントローラ（indexアクション）
- `app/views/books/index.html.erb` - 書籍一覧ビュー
- `app/assets/stylesheets/books.css` - 書籍関連CSS
- `spec/requests/books_spec.rb` - リクエストスペック

### 変更
- `config/routes.rb` - booksリソースルート追加
- `app/models/book.rb` - ノルマ計算・ソートスコープ追加
- `app/controllers/users/sessions_controller.rb` - ログイン後リダイレクト先をbooks_pathへ変更
- `spec/models/book_spec.rb` - ノルマ計算スペック追加

## データフロー

```
GET /books (認証必須)
  → BooksController#index
  → current_user.books.for_index_list (スコープ)
    → 未了本を期限順、完了本を最後に
  → books/index.html.erb
    → 書籍カード × N (BEMコンポーネント)
    または Empty State
```

## モデル設計

### Book model 追加メソッド

```ruby
# 今日のノルマ（残ページ÷残日数、切り上げ）
def daily_quota
  return 0 if completed?
  remaining = target_pages - current_page
  return 0 if remaining <= 0
  days = [(deadline - Date.current).to_i, 1].max
  (remaining.to_f / days).ceil
end

# 進捗率（%）
def progress_percentage
  return 100 if completed?
  return 0 if target_pages.zero?
  ((current_page.to_f / target_pages) * 100).round
end

# 残り日数
def days_remaining
  (deadline - Date.current).to_i
end

# 賞味期限ビジュアライザーCSSクラス
def deadline_urgency_class
  return '' if completed?
  days = days_remaining
  if days <= 1
    'book-card__cover--urgent-high'
  elsif days <= 3
    'book-card__cover--urgent-medium'
  elsif days <= 7
    'book-card__cover--urgent-low'
  else
    ''
  end
end
```

### Book scopeの設計

```ruby
scope :for_index_list, -> {
  # 未了本を期限順→読了本を期限順の順
  order(
    Arel.sql("CASE WHEN status = #{statuses[:completed]} THEN 1 ELSE 0 END"),
    :deadline
  )
}
```

## ルーティング設計

```ruby
resources :books, only: [:index]
```

将来の詳細画面・登録画面のための `only:` を使用。

## ビュー設計

### books/index.html.erb

```erb
<% if @books.empty? %>
  # Empty State
<% else %>
  # 書籍カード一覧
<% end %>
```

### 書籍カード構造（BEM）

```
.book-list
  .book-card
    .book-card__cover (+ urgency class)
      img / placeholder
    .book-card__body
      .book-card__title
      .book-card__deadline（残り日数）
      .book-card__progress
        .book-card__progress-bar
        .book-card__progress-text
      .book-card__quota
```

## CSS設計（BEM）

賞味期限ビジュアライザー:
```css
.book-card__cover--urgent-low   { filter: sepia(30%); opacity: 0.85; }
.book-card__cover--urgent-medium { filter: sepia(60%); opacity: 0.7; }
.book-card__cover--urgent-high  { filter: sepia(90%); opacity: 0.55; }
```
