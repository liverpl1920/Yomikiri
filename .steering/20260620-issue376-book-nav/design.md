# 設計書

## 概要

書籍詳細画面に前後ナビゲーションを追加する。

## 変更ファイル

### `app/models/book.rb`

`reading_round` 用の `previous_book`（同タイトル前回分）とは別に、全書籍ナビゲーション用の2メソッドを `public` セクション末尾に追加。

```ruby
# 詳細画面の前後ナビゲーション用（ID順）
# 同ユーザーの書籍で、自身より ID が小さい最大のものを返す
def prev_book_by_id
  return nil if new_record? || user.nil?
  user.books.where("id < ?", id).order(id: :desc).first
end

# 同ユーザーの書籍で、自身より ID が大きい最小のものを返す
def next_book_by_id
  return nil if new_record? || user.nil?
  user.books.where("id > ?", id).order(id: :asc).first
end
```

### `app/views/books/show.html.erb`

`book-show__actions` の上に `book-show__nav` ブロックを追加。

```erb
<%# 前後ナビゲーション (Issue #376) %>
<div class="book-show__nav">
  <% if (prev_book = @book.prev_book_by_id) %>
    <%= link_to book_path(prev_book), class: "btn btn--outline book-show__nav-btn" do %>
      ＜ 前の本
    <% end %>
  <% else %>
    <span class="book-show__nav-btn book-show__nav-btn--disabled" aria-disabled="true">＜ 前の本</span>
  <% end %>

  <% if (next_book = @book.next_book_by_id) %>
    <%= link_to book_path(next_book), class: "btn btn--outline book-show__nav-btn" do %>
      次の本 ＞
    <% end %>
  <% else %>
    <span class="book-show__nav-btn book-show__nav-btn--disabled" aria-disabled="true">次の本 ＞</span>
  <% end %>
</div>
```

### `app/assets/stylesheets/books.css`

`.book-show__nav` と `.book-show__nav-btn--disabled` を追加。

```css
.book-show__nav {
  display: flex;
  justify-content: space-between;
  gap: var(--spacing-md);
  margin-bottom: var(--spacing-md);
}

.book-show__nav-btn {
  min-width: 120px;
  text-align: center;
}

.book-show__nav-btn--disabled {
  min-width: 120px;
  text-align: center;
  color: var(--color-text-muted, #aaa);
  cursor: not-allowed;
  pointer-events: none;
  border: 1px solid var(--color-border, #ddd);
  border-radius: var(--border-radius-md, 4px);
  padding: var(--spacing-sm) var(--spacing-md);
  display: inline-flex;
  align-items: center;
  justify-content: center;
}
```

### `spec/models/book_spec.rb`

`prev_book_by_id` / `next_book_by_id` のユニットテストを追加。

## 設計上の判断

- **メソッド名**: 既存の `previous_book`（同タイトル再読追跡用）と混同しないよう `prev_book_by_id` / `next_book_by_id` と命名
- **ロジック**: 単純に `id` 順で前後を取得。将来的にソート順を変更する場合はここを改修する
- **UI**: 前後の本が存在しない場合は非活性スタイルのスパンを表示（アクセシビリティのため `aria-disabled` 付与）
- **配置**: `book-show__actions` の上に配置し、既存のボタン群とは視覚的に区別する
