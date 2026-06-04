# 設計書

## アーキテクチャ概要
既存の MVC アーキテクチャに基づき、`Book` モデルの拡張とビューの変更、および DB マイグレーションを行います。

## コンポーネント設計

### 1. データベーススキーマ (`books` テーブル)
- **マイグレーションによる変更**:
  - `total_pages` を `pages` にリネームします。
  - 既存データ移行: `target_pages` の値が存在して `total_pages` と異なる場合、移行後の `pages` を `target_pages` で更新します。
  - `target_pages` カラムを削除します。
  - `translator` (string, null: true) カラムを追加します。
  - `publisher` (string, null: true) カラムを追加します。

### 2. `Book` モデル
- `total_pages` と `target_pages` のバリデーションを削除し、`pages` に関するバリデーションを追加します。
- `current_page` が `pages` を超えないバリデーションに変更します。
- `remaining_pages`、`daily_quota`、`progress_percentage` などのロジックを `pages` カラムを利用するように修正します。
- 検索スコープに `:publisher_like` を追加します。
- `Book.filtered_for_index` に `publisher` 検索のフィルタを追加します。

### 3. ビューおよび JavaScript (Stimulus)
- **フォーム (`_form.html.erb`)**:
  - `total_pages` と `target_pages` を削除し、`pages` フィールドを追加。
  - `translator` フィールド（任意）を追加。
  - `publisher` フィールド（任意）を追加。
- **Stimulus コントローラ (`book_form_controller.js`)**:
  - `syncTargetPages` 処理を削除。
  - `calculateQuota` を `pages` を利用するように修正。
  - `_fillFormFromSearch` にて、`pages`、`translator`、`publisher` の自動反映処理を追加。
- **詳細画面 (`show.html.erb`) / 一覧画面 (`index.html.erb`)**:
  - 翻訳者および出版社を表示。
  - ページ数は単一の「ページ数」として表示。
  - 検索フォームに出版社検索フィールドを追加。

### 4. API連携 (`books_controller.rb`)
- `search_by_isbn` と `search_by_title` で openBD / Google Books API から `publisher` と `translator` を取得し、フロントエンドに返却します。
  - Google Books: `info["publisher"]` から `publisher` を取得。
  - openBD: `summary.publisher` から `publisher` を、`DescriptiveDetail.Contributor` から `translator` (ContributorRole `"B06"`) を抽出。

## テスト戦略
- **ユニットテスト (`book_spec.rb`, `user_spec.rb`)**:
  - `total_pages` / `target_pages` を `pages` に置き換え。
  - `publisher` と `translator` の動作確認。
- **システムテスト / リクエストテスト**:
  - `pages` での登録、進捗更新、完了が正しく動くことを確認。
  - 出版社検索の確認。

## ディレクトリ構造
```text
db/migrate/[timestamp]_modify_books_for_enhancements.rb
app/models/book.rb
app/controllers/books_controller.rb
app/javascript/controllers/book_form_controller.js
app/views/books/_form.html.erb
app/views/books/show.html.erb
app/views/books/index.html.erb
config/locales/ja.yml
spec/... (関連テストファイル)
```

## 実装の順序
1. DBマイグレーション作成・実行
2. `Book` モデルの実装およびテスト修正
3. `BooksController` のAPI検索・ストロングパラメータ修正
4. Stimulus `book_form_controller.js` 修正
5. フォームおよび各ビューの修正
6. 全体テストの実行・動作検証
