# Issue #361 設計書：著者複数人の省略表示

## 変更ファイル一覧

| ファイル | 変更種別 | 概要 |
|----------|---------|------|
| `app/helpers/books_helper.rb` | 修正 | `book_author_display` メソッドを追加 |
| `app/views/books/index.html.erb` | 修正 | 著者表示を `book_author_display(book)` に変更 |
| `spec/helpers/books_helper_spec.rb` | 修正 | `book_author_display` のテストを追加 |

## ヘルパーメソッド設計

```ruby
# app/helpers/books_helper.rb
def book_author_display(book)
  authors = book.authors
  if authors.length > 1
    "#{authors.first} ..."
  else
    book.author.to_s
  end
end
```

## ビュー変更箇所

```erb
# Before
<% if book.author.present? %>
  <p class="book-card__author"><%= book.author %></p>
<% end %>

# After
<% if book.author.present? %>
  <p class="book-card__author"><%= book_author_display(book) %></p>
<% end %>
```

## テスト設計

| ケース | 入力 | 期待出力 |
|--------|------|---------|
| 著者が1人 | `author: "著者A"` | `"著者A"` |
| 著者が複数人（カンマ区切り） | `author: "著者A, 著者B"` | `"著者A ..."` |
| 著者が複数人（読点区切り） | `author: "著者A、著者B、著者C"` | `"著者A ..."` |
| 著者が空 | `author: ""` | `""` |
