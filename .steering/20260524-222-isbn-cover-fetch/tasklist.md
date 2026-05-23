# タスクリスト - ISSUE#222 書影取得をISBNベース取得に対応

## タスク

- [ ] マイグレーション作成（books.isbnカラム追加）
- [ ] マイグレーション実行
- [ ] Bookモデルにisbnバリデーション追加
- [ ] BooksController: search_by_isbnの返り値にisbnを追加
- [ ] BooksController: search_by_titleの返り値にisbnを追加
- [ ] BooksController: book_params / edit_book_paramsにisbnを追加
- [ ] フォームビュー: hidden_field :isbn を追加
- [ ] book_form_controller.js: ISBNフィールドを検索結果から埋める
- [ ] book_search_controller.js: ISBNフィールドを検索結果から埋める
- [ ] テスト追加（検索レスポンスにisbnが含まれること）
- [ ] テスト追加（ISBN付き書籍の作成・保存）
- [ ] RSpec・RuboCop 通過確認

## 振り返り

（実装完了後に記載）
