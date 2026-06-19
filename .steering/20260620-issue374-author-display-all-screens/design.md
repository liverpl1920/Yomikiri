# 設計

## 実装方針

Issue #361 で `BooksHelper#book_author_display` が実装済みのため、各ビューで `book.author` を直接表示している箇所をこのヘルパーメソッドの呼び出しに置き換える。

`BooksHelper` は Rails の Helper 機能により全コントローラー・全ビューで自動的に利用可能（`ApplicationHelper` がすべての Helper を include する仕組み）なため、新たな include は不要。

## 変更ファイル一覧

| ファイル | 変更内容 |
|---|---|
| `app/views/books/show.html.erb` | L53: `@book.author` → `book_author_display(@book)` |
| `app/views/dashboards/show.html.erb` | L46: `book.author` → `book_author_display(book)` |
| `app/views/dashboards/show.html.erb` | L194: `book.author` → `book_author_display(book)` |
| `app/views/dashboards/_random_lookback.html.erb` | L41: `random_book.author` → `book_author_display(random_book)` |
| `app/views/mypages/show.html.erb` | L160: `book.author` → `book_author_display(book)` |

## 変更しないもの

- `BooksHelper#book_author_display` の実装（変更不要）
- `Book#authors` モデルメソッド（変更不要）
- 著者が空文字・nil の場合の条件分岐ガード（既存のまま維持）
