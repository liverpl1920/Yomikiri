# 要求内容

## 概要

アプリ内のすべての画面（一覧画面、詳細画面、ダッシュボード、マイページなど）で、著者が2名以上の場合に1人目のみを表示し、以降を「...」で省略する表示仕様を統一適用する。

## 背景

Issue #361 にて `BooksHelper#book_author_display` メソッドが実装済みで、`books/index.html.erb`（一覧画面）には適用済み。
しかし、以下の画面では未適用のまま直接 `book.author` を表示している：
- `books/show.html.erb`（詳細画面）
- `dashboards/show.html.erb`（ダッシュボード）
- `dashboards/_random_lookback.html.erb`（振り返りカード）
- `mypages/show.html.erb`（マイページ読了履歴）

アンソロジーや共著など著者が多数並ぶケースでレイアウトが崩れるため、全画面で統一する。

## 実装対象の機能

### 1. 全画面への著者省略表示の統一適用

以下のルールで著者名を表示する：
- 著者が1人の場合：従来通りそのまま著者名を表示
- 著者が2人以上の場合：1人目の氏名のみ抽出し、末尾に ` ...` を付加して表示
- 例：「青木さやか, 朝井リョウ, 朝比奈秋」→「青木さやか ...」

## 受け入れ条件

### 全画面統一適用
- [ ] `books/show.html.erb` の著者表示が `book_author_display(@book)` を使用している
- [ ] `dashboards/show.html.erb` の読書中書籍の著者表示が `book_author_display(book)` を使用している
- [ ] `dashboards/show.html.erb` の最近読了した本の著者表示が `book_author_display(book)` を使用している
- [ ] `dashboards/_random_lookback.html.erb` の著者表示が `book_author_display(random_book)` を使用している
- [ ] `mypages/show.html.erb` の読了履歴の著者表示が `book_author_display(book)` を使用している
- [ ] 既存の `books_helper_spec.rb` テストがすべて通る
- [ ] `bundle exec rspec` がすべて通る
- [ ] `bundle exec rubocop` がクリーンである

## 成功指標

- 全画面で著者表示ロジックが `BooksHelper#book_author_display` に統一される
- 複数著者の場合にどの画面でも省略表示が適用される

## スコープ外

- `book_author_display` メソッド自体の変更（既に実装済み）
- 著者フィールドの編集・バリデーション変更

## 参照ドキュメント

- `docs/architecture.md` - アーキテクチャ設計書
- `docs/development-guidelines.md` - 開発ガイドライン
