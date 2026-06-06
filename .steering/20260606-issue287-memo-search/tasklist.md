# タスクリスト: Issue #287 メモ検索機能

## タスク一覧

- [x] ブランチ作成 (`feature/#287-memo-search`)
- [x] BookMemo モデルに `content_like` スコープを追加
- [x] BooksController の `index` アクションにメモ検索ロジックを追加
- [x] `app/views/books/index.html.erb` にメモ検索フォームを追加
- [x] `app/views/books/_memo_search_results.html.erb` を新規作成
- [x] `app/assets/stylesheets/books.css` にメモ一覧のスタイルを追加
- [x] `spec/models/book_memo_spec.rb` に `content_like` スコープのテストを追加
- [x] `spec/requests/books_index_spec.rb` にメモ検索のリクエストスペックを追加
- [x] `spec/system/books/memo_search_spec.rb` を新規作成
- [x] `bundle exec rspec` を実行してテストが通ることを確認
- [x] `bundle exec rubocop` を実行してエラーがないことを確認
- [x] コミット・プッシュ・PR作成

## 振り返り

### 実装について
- `memo_keyword` パラメータの有無でメモ一覧と本の一覧を切り替える設計にした
- `current_user.books.ids` でアクセス制御を担保し、他ユーザーのメモを検索対象から除外
- 既存の `render_book_memo_content` ヘルパーを流用して装飾記法をメモ一覧にも適用
- メモ検索フォームとクリアリンクに一意のIDを付与し、システムスペックのアンビギュアス問題を回避

### 発見した問題
- mainブランチ取り込み時点で `search_filter_autocomplete_spec.rb`（#304追加）と `suggestions` 関連テストが既に失敗していた（今回の変更とは無関係）

### PR
- PR #308: https://github.com/liverpl1920/Yomikiri/pull/308
