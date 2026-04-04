# 要求内容

## 概要

積読一覧画面（`/books`）の「+ 本を追加する」ボタンと「最初の本を登録して始める」ボタンが `disabled` 状態のため、クリックしても何も起こらない。この2つのボタンを `link_to` に置き換えて書籍登録画面（`/books/new`）へ遷移できるようにする。

## 背景

`BooksController#new` / `#create` はすでに実装済みで、`new_book_path`（`GET /books/new`）も有効なルートとして存在する。しかし、Issue #14（書籍登録機能）の実装以前に作られたビューで暫定措置として `disabled` 属性が付与されたボタンが残ったままになっており、ビューの更新だけが漏れている。

## 実装対象の機能

### 1. ヘッダーの「+ 本を追加する」ボタン修正

- `<button disabled>` を `<%= link_to ..., new_book_path %>` に置き換える
- CSSクラス `btn btn--primary books-index__add-btn` を維持する

### 2. Empty State の「最初の本を登録して始める」ボタン修正

- `<button disabled>` を `<%= link_to ..., new_book_path %>` に置き換える
- CSSクラス `btn btn--primary btn--lg` を維持する

## 受け入れ条件

### ヘッダーボタン
- [ ] 「+ 本を追加する」をクリックすると `/books/new` へ遷移する
- [ ] `disabled` 属性が付いていない
- [ ] 見た目（スタイル）が変わらない

### Empty State ボタン
- [ ] 「最初の本を登録して始める」をクリックすると `/books/new` へ遷移する
- [ ] `disabled` 属性が付いていない
- [ ] 見た目（スタイル）が変わらない

## 成功指標

- ボタンクリック時に `/books/new` へ遷移できること
- 既存の RSpec テストが全件通過すること

## スコープ外

- ボタンのスタイル変更
- 書籍登録フォームの変更
- 他ページの変更

## 参照ドキュメント

- `docs/development-guidelines.md` - 開発ガイドライン
- `app/views/books/index.html.erb` - 修正対象ファイル
