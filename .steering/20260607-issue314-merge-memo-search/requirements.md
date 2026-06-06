# Issue #314: メモの検索フォームを既存の本の検索フォームへ統合する

## 背景

現在、一覧画面（`books#index`）には「本の検索フォーム」（書籍名・著者名・ジャンル等）と「メモ検索フォーム」の2つのフォームが独立して存在している。
これをシームレスな1つのUIに集約することで、ユーザーが検索窓を使い分ける手間を解消する。

## 期待される挙動

- 本の検索フォームに「メモ内容」のキーワード入力欄を追加する
- 1回の検索で、本のタイトル・著者名とメモの内容を同時に検索できる
- 検索結果画面にマッチした「本の一覧」を表示し、メモにマッチした場合はそのメモが紐づく本も含めて表示する
- 独立したメモ検索フォームを削除する（UIを1つに集約）

## 実装方針

### コントローラー（`books_controller.rb`）

- `normalized_index_search_params` に `:memo_keyword` を追加する
- `index` アクション：
  - メモキーワードが指定された場合、本のタイトル・著者フィルタリングに加え、メモの内容で紐づく本の ID セットを取り出し、`OR` で結合して `@books` に返す
  - `@memo_search_active` フラグを廃止し、すべて `@books` として返す
  - メモにマッチした本は `@matched_memo_book_ids` などで保持し、View 側でハイライト表示に使う（オプション）
- 独立した `@memo_keyword` / `@memo_search_active` の分岐ロジックを削除する

### モデル（`book.rb`）

- `filtered_for_index` に `memo_keyword` パラメータを追加し、関連する `BookMemo#content_like` を使って本IDをサブクエリまたはIN句で絞り込む

### ビュー（`app/views/books/index.html.erb`）

- 独立したメモ検索フォーム（`#memo-search-form`）を削除する
- 既存の本の検索フォームにメモ内容キーワード欄を追加する
- `@memo_search_active` の分岐を削除し、検索結果は常に `@books` として本の一覧で表示する

### ビュー（`app/views/books/_memo_search_results.html.erb`）

- 独立したメモ検索結果パーシャルは不要になるため削除する

### CSS（`app/assets/stylesheets/books.css`）

- メモ検索フォーム専用のスタイル（`.books-index__memo-search` 等）を削除する

## 対象ファイル

### 修正
- `app/controllers/books_controller.rb`
- `app/models/book.rb`
- `app/views/books/index.html.erb`
- `app/assets/stylesheets/books.css`

### 削除
- `app/views/books/_memo_search_results.html.erb`

### テスト
- `spec/requests/books_index_spec.rb`（メモ統合検索のリクエストスペック追加/修正）
- `spec/models/book_spec.rb`（`filtered_for_index` のメモキーワード対応テスト追加）
