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
- Rails 7 の Turbo Streams を利用し、非常にシンプルかつクリーンに非同期でのDOM更新（メモの追加、空時のメッセージ削除、フォームの初期化）を実現できました。
- コントローラー側で `respond_to` を導入し、従来の HTML リダイレクト（フォールバック）と Turbo Streams の両方を適切にサポートしました。
- テスト面でも、Turbo Streams 形式でのリクエストに対応した Request Spec の追加・修正を行い、正常な動作を保証しました。
- 画面遷移を伴わないため、スクロール位置が保持され連続してメモを追加する際のUXが大幅に改善されました。
