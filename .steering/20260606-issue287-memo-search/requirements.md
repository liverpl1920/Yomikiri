# Issue #287: 一覧画面でメモの内容で検索できるようにする（メモ一覧を表示）

## 要件

### 背景
現在の一覧画面は本単位での表示となっているが、過去に書いたメモを内容から探したいケースがある。

### 機能要件
1. 一覧画面（`books#index`）にメモ検索フォームを追加する
2. 入力されたキーワードをメモ本文（`book_memos.content`）で部分一致検索（ILIKE）する
3. 検索結果はメモの一覧形式で表示する（本の一覧ではない）
4. メモ一覧には以下の情報を表示する：
   - メモ内容（content）
   - ページ番号（page_number）
   - 所属する本のタイトル（書籍詳細ページへのリンク）
   - 作成日時

### 非機能要件
- 既存の本の一覧検索機能との共存（別タブや別セクションとして表示）
- 認証済みユーザー自身のメモのみ検索対象
- SQLインジェクション対策（`sanitize_sql_like` を使用）
- BEM記法でのCSS追加

## 対象ファイル

### 新規作成
- `app/views/books/_memo_search_results.html.erb`（メモ一覧パーシャル）

### 修正
- `app/models/book_memo.rb`（`content_like` スコープ追加）
- `app/controllers/books_controller.rb`（`index`アクションにメモ検索ロジック追加）
- `app/views/books/index.html.erb`（メモ検索フォームとメモ一覧表示の追加）
- `app/assets/stylesheets/books.css`（メモ一覧のスタイル追加）

### テスト
- `spec/models/book_memo_spec.rb`（`content_like`スコープのテスト追加）
- `spec/requests/books_index_spec.rb`（メモ検索のリクエストスペック追加）
- `spec/system/books/memo_search_spec.rb`（E2Eスペック新規作成）
