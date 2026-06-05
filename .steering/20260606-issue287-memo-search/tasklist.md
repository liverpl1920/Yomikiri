# タスクリスト: Issue #287 メモ検索機能

## タスク一覧

- [ ] ブランチ作成 (`feature/#287-memo-search`)
- [ ] BookMemo モデルに `content_like` スコープを追加
- [ ] BooksController の `index` アクションにメモ検索ロジックを追加
- [ ] `app/views/books/index.html.erb` にメモ検索フォームを追加
- [ ] `app/views/books/_memo_search_results.html.erb` を新規作成
- [ ] `app/assets/stylesheets/books.css` にメモ一覧のスタイルを追加
- [ ] `spec/models/book_memo_spec.rb` に `content_like` スコープのテストを追加
- [ ] `spec/requests/books_index_spec.rb` にメモ検索のリクエストスペックを追加
- [ ] `spec/system/books/memo_search_spec.rb` を新規作成
- [ ] `bundle exec rspec` を実行してテストが通ることを確認
- [ ] `bundle exec rubocop` を実行してエラーがないことを確認
- [ ] コミット・プッシュ・PR作成
