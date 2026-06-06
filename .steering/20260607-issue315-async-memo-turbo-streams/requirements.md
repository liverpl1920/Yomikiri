# Issue #315 要件定義

## 概要
メモ追加時に画面全体をリロードせず、Turbo Streams を使って非同期でメモリストに即時反映させる。

## 現状の課題
- `BookMemosController#create` で保存成功時に `redirect_to @book` を行っているため、フルページリロードが発生する。
- 連続してメモを投稿したいユーザーが毎回ページ最上部に戻されてしまい、UX が悪い。

## 期待される挙動
1. メモ追加フォームで「メモを追加する」を押しても**画面全体のリロードが発生しない**こと。
2. 新規追加されたメモがメモリスト（`memo-timeline__list`）の**末尾**に非同期で追加されること。
   - 「まだメモがありません」のメッセージがある場合は非表示にして、リストを表示すること。
3. メモ追加成功後、入力フォーム内のテキスト（`content` と `page_number`）が**自動でクリア**されること。
4. バリデーションエラー時は現行通り422でエラーメッセージを表示すること（フォームに留まる）。

## 対象ファイル
- `app/controllers/book_memos_controller.rb` — `create` アクションを `respond_to` で turbo_stream 対応
- `app/views/book_memos/create.turbo_stream.erb` — 新規作成
- `app/views/book_memos/_book_memo.html.erb` — 新規作成（メモ1件のパーシャル）
- `app/views/books/show.html.erb` — メモリスト周辺に `id` を付与
- `spec/requests/book_memos_spec.rb` — create のリダイレクト仕様をturbo_stream対応に修正

## 非機能要件
- Turbo Drive が無効（`data-turbo: false`）のフォームをそのまま使っていた箇所を `data-turbo: true`（またはデフォルト）に変更する。
- エラー時の挙動は既存と同一（422 + books/show の再描画）。
