# タスクリスト - Issue #143: タイトル入力から自動でISBN・書影を取得

## フェーズ1: 準備

- [x] git checkout main && git pull origin main
- [x] git checkout -b feature/#143-title-isbn-autofetch

## フェーズ2: フロントエンド実装

- [x] `book_form_controller.js` に自動取得メソッドを追加
  - `autoFetchByTitle()` - タイトルからISBN/書影を取得
  - `fetchByIsbn()` - ISBNから書影を取得
  - `_showIsbnFallback()` / `_hideIsbnSection()` ヘルパー
  - `_fillFormFromSearch()` フォーム入力ヘルパー
- [x] `_form.html.erb` を更新
  - タイトルフィールドに `blur` イベントと `target` を追加
  - タイトルステータス表示要素を追加
  - ISBNフォールバックセクションを追加（初期非表示）
- [x] `books.css` にスタイルを追加
  - `.book-form__isbn-section` (非表示切り替え含む)
  - `.book-form__isbn-input-group`
  - `.book-form__title-status`
  - `.book-form__isbn-status`

## フェーズ3: テスト

- [x] 既存のシステムスペックが通ることを確認
- [x] 新機能のシステムスペックを追加 (`spec/system/books/isbn_autofetch_spec.rb`)
  - タイトル入力→自動取得成功ケース
  - タイトル入力→自動取得失敗→ISBNフォールバック表示ケース
  - ISBN手動入力→書影取得成功ケース

## フェーズ4: 品質確認

- [x] bundle exec rspec で全テスト通過
- [x] bundle exec rubocop でエラーなし

## 振り返り

（実装完了後に記載）
