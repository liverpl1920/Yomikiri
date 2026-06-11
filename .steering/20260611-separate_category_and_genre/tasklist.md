# タスクリスト

## 🚨 タスク完全完了の原則

**このファイルの全タスクが完了するまで作業を継続すること**

### 必須ルール
- **全てのタスクを`[x]`にすること**
- 未完了タスク（`[ ]`）を残したまま作業を終了しない

---

## フェーズ1: データベースとモデルの変更

- [x] マイグレーションの作成と適用
  - [x] `rails g migration AddCategoryToBooks category:integer`
  - [x] マイグレーションファイルを修正し `default: 0, null: false` を追加
  - [x] `rails db:migrate` の実行
- [x] Book モデル of の修正
  - [x] `app/models/book.rb` に `enum :category` とバリデーションを追加
- [x] ロケールファイルの修正
  - [x] `config/locales/ja.yml` に `category` 属性名および各 enum の日本語訳を追加
- [x] ファクトリの修正
  - [x] `spec/factories/books.rb` にデフォルトの `category` を追加
- [x] モデルスペックの追加と実行
  - [x] `spec/models/book_spec.rb` に `category` のテストを追加
  - [x] `bundle exec rspec spec/models/book_spec.rb` の実行

## フェーズ2: コントローラとビューの変更

- [x] コントローラの修正
  - [x] `app/controllers/books_controller.rb` の `book_params` と `edit_book_params` に `:category` を追加
- [x] ビューの修正
  - [x] `app/views/books/_form.html.erb` に種類 (category) のセレクトボックスを追加
  - [x] `app/views/books/show.html.erb` に種類 (category) の表示項目を追加
  - [x] `app/views/books/index.html.erb` に種類 (category) のバッジを追加
- [x] スタイルの追加
  - [x] `app/assets/stylesheets/books.css` に `.book-card__category` スタイルを定義

## フェーズ3: 品質チェックと修正

- [x] RSpec の実行
  - [x] `bundle exec rspec` を実行し、全テストがパスすることを確認
- [x] RuboCop の実行
  - [x] `bundle exec rubocop` を実行し、コード規約違反がないことを確認

## フェーズ4: ドキュメント更新

- [x] 実装後の振り返り（このファイルの下部に記録）

---

## 実装後の振り返り

### 実装完了日
2026-06-11

### 計画と実績の差分

**計画と異なった点**:
- 概ね計画通りに実装を進めることができました。

**新たに必要になったタスク**:
- `spec/models/book_spec.rb` で `category` のデフォルト値を検証する際、明示的に `nil` を渡して `create(:book, category: nil)` すると `presence: true` のバリデーションに失敗するため、引数から `category` を除外して `Book.create!` を呼び出す形に修正しました。

### 学んだこと

**技術的な学び**:
- Railsの `enum` は、DB側でデフォルト値（`0`など）が定義されていても、ActiveRecordレベルで明示的に `nil` が指定されると `nil` のまま保存しようとしてしまい、`presence: true` バリデーションで弾かれる。デフォルト値のフォールバックを検証する場合は、属性自体を指定せずに作成することが望ましい。

**プロセス上の改善点**:
- ステアリングファイルと `task.md` の二重管理において、進捗状況を同期させながら実装を行うことで、今やるべきタスクが明確化され手戻りなく進められた。

### 次回への改善提案
- モデル作成・更新時のデフォルト値のテストでは、あらかじめファクトリの設定とバリデーションの関係性を踏まえてテストコードを記述する。
