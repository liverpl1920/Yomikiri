# 設計 - ISSUE#222 書影取得をISBNベース取得に対応

## アプローチ

### 1. DBマイグレーション
- `books` テーブルに `isbn` カラム（string, nullable）を追加
- ISBN-13形式（13桁）またはISBN-10形式（10桁/9桁+X）を保存

### 2. Bookモデル更新
- `isbn` カラムの存在をモデルが認識するよう、バリデーション追加
  - フォーマット検証: `\A(?:\d{13}|\d{9}[\dX])\z` または空白許可

### 3. BooksControllerの検索レスポンス更新
- `search_by_isbn` の返り値ハッシュに `isbn:` キーを追加
- `search_by_title` の返り値ハッシュに `isbn:` キーを追加

### 4. Strong Parameters更新
- `book_params` に `:isbn` を追加
- `edit_book_params` に `:isbn` を追加

### 5. フォームビュー更新
- `f.hidden_field :isbn` を追加（`cover_image_url` と同様）

### 6. JavaScript更新
- `book_form_controller.js`: `_fillFormFromSearch` で ISBN フィールドを埋める
- `book_search_controller.js`: `_fillForm` で ISBN フィールドを埋める

### 7. テスト追加
- 検索レスポンスに `isbn` が含まれることを確認するテスト
- ISBNが書籍作成時に保存されることを確認するテスト

## ファイル一覧
- `db/migrate/YYYYMMDDHHMMSS_add_isbn_to_books.rb`（新規作成）
- `app/models/book.rb`（更新）
- `app/controllers/books_controller.rb`（更新）
- `app/views/books/_form.html.erb`（更新）
- `app/javascript/controllers/book_form_controller.js`（更新）
- `app/javascript/controllers/book_search_controller.js`（更新）
- `spec/requests/books_search_spec.rb`（テスト追加）
- `spec/requests/books_spec.rb`（テスト追加）
