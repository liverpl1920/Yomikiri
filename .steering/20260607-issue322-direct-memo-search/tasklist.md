# Issue #322: タスクリスト - 検索結果画面において、メモがヒットした場合は「本」ではなく「メモ自体」を直接表示する

## タスク

- [x] ステアリングファイル作成（requirements.md / design.md / tasklist.md）
- [x] ブランチ作成: `feature/#322-direct-memo-search`
- [x] `Book.filtered_for_index` から `memo_keyword` パラメータ対応を削除
- [x] `books_controller.rb#index` を更新し、本に関する検索とメモに関する検索を分離して `@books` と `@memos` を取得するように変更
- [x] `books/index.html.erb` にメモ検索結果エリアを追加し、本とメモが別々に表示されるようにUI変更
- [x] `books.css` にメモ検索結果表示用のスタイルを追加
- [x] RSpec: `spec/models/book_spec.rb` の `filtered_for_index` テストを修正
- [x] RSpec: `spec/requests/books_index_spec.rb` のリクエストスペックにメモ直接表示のテストを追加・修正
- [x] RSpec: 必要に応じてシステムテスト等他のテストを修正
- [x] `bundle exec rspec` でテスト実行・確認
- [x] `bundle exec rubocop` で静的解析実行・確認
- [x] コミット & プッシュ & PR 作成

## 振り返り

- `Book.filtered_for_index` から `memo_keyword` のフィルタリングを除外し、`BooksController#index` で本とメモの検索処理を明確に分離した。
- 本に関する検索条件がない状態で `memo_keyword` が指定された場合は、本のリスト（`@books`）は空になり、メモの検索結果（`@memos`）だけが表示される挙動を実装した。これにより意図しない全本表示を防止できた。
- RSpec system spec で `dom_id` の `NoMethodError` が発生したが、`ActionView::RecordIdentifier.dom_id` を明示的に呼ぶことで解決した。
- PR: https://github.com/liverpl1920/Yomikiri/pull/325
