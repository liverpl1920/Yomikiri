# タスクリスト - ISSUE#222 書影取得をISBNベース取得に対応

## タスク

- [x] マイグレーション作成（books.isbnカラム追加）
- [x] マイグレーション実行
- [x] Bookモデルにisbnバリデーション追加
- [x] BooksController: search_by_isbnの返り値にisbnを追加
- [x] BooksController: search_by_titleの返り値にisbnを追加
- [x] BooksController: book_params / edit_book_paramsにisbnを追加
- [x] フォームビュー: hidden_field :isbn を追加
- [x] book_form_controller.js: ISBNフィールドを検索結果から埋める
- [x] book_search_controller.js: ISBNフィールドを検索結果から埋める
- [x] テスト追加（検索レスポンスにisbnが含まれること）
- [x] テスト追加（ISBN付き書籍の作成・保存）
- [x] RSpec・RuboCop 通過確認

## 振り返り

### 実装完了日
2026-05-24

### 計画と実績の差分
- 計画通りに全タスクを完了
- 既存の検索ロジックは既にISBNベースの書影取得をしていたため、主な変更は「ISBNをDBに保存する」部分のみ
- タイトル検索・ISBN検索の両方でレスポンスに`isbn`キーを追加し、フォームに自動入力するよう実装

### 学んだこと
- 既存コードがすでに検索時にISBNを抽出・活用していたため、「DBへの保存」が核心的な変更だった
- ISBN-10（9桁＋Xまたは10桁数字）とISBN-13の両フォーマットをバリデーションで許容する必要がある
- JS側は`document.getElementById`でhidden_fieldにアクセスするシンプルな実装で十分

### 次回への改善提案
- 既存書籍（ISBN未保存）に対してバックグラウンドでISBNを付与するバッチ処理の検討
- 編集画面でISBNを変更した際に書影を再取得するUI改善の余地あり
