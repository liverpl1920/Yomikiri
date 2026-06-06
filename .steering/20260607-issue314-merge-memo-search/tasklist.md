# Issue #314: タスクリスト - メモ検索フォームを本の検索フォームに統合

## タスク

- [x] ステアリングファイル作成（requirements.md / design.md / tasklist.md）
- [x] ブランチ作成: `feature/#314-merge-memo-search`
- [x] `Book.filtered_for_index` に `memo_keyword` パラメータ対応を追加
- [x] `books_controller.rb#index` の分岐ロジックを整理（`@memo_search_active` 削除）
- [x] `books_controller.rb#normalized_index_search_params` に `:memo_keyword` を追加
- [x] `books/index.html.erb` のメモ検索フォームを本の検索フォームに統合
- [x] `books/index.html.erb` の `@memo_search_active` 分岐を削除
- [x] `books/_memo_search_results.html.erb` パーシャルを削除
- [x] `books.css` のメモ検索フォーム専用スタイルを削除
- [x] RSpec: `spec/models/book_spec.rb` にメモキーワードフィルタのテスト追加
- [x] RSpec: `spec/requests/books_index_spec.rb` に統合検索のリクエストスペック追加/修正
- [x] `bundle exec rspec` でテスト実行・確認
- [x] `bundle exec rubocop` で静的解析実行・確認
- [/] コミット & プッシュ & PR 作成

## 振り返り

（完了後に記載）
