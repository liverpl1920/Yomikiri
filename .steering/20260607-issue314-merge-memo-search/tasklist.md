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
- [x] コミット & プッシュ & PR 作成

## 振り返り

- `Book.filtered_for_index` に `memo_keyword` 対応を追加する際、サブクエリのスコープを付けることで他ユーザーのメモを自動的に除外できた。
- システムスペックの修正で「検索」ボタンが複数存在する曖昧さ問題が発生したが、ボタンに ID を付与することで解決した。
- 旧実装のメモ検索スペック（メモ一覧形式を期待）を新UI（本のカード一覧形式）に合わせて全部書き直した。
- PR: https://github.com/liverpl1920/Yomikiri/pull/316
