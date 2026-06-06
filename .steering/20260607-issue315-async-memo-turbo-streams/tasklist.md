# Issue #315 タスクリスト

## タスク

- [x] `app/views/book_memos/_book_memo.html.erb` — メモ1件パーシャルを作成
- [x] `app/views/books/show.html.erb` — メモリスト・フォームに `id` 付与、フォームの `data-turbo: false` を削除
- [x] `app/controllers/book_memos_controller.rb` — `create` を `respond_to` で turbo_stream 対応
- [x] `app/views/book_memos/create.turbo_stream.erb` — Turbo Stream テンプレート作成
- [x] `spec/requests/book_memos_spec.rb` — turbo_stream リクエストのテストを追加・修正
- [x] RSpec 実行・確認（51 examples, 0 failures）
- [x] RuboCop 実行・確認（no offenses detected）

## 振り返り
