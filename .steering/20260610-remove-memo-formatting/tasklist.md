# タスクリスト

- [x] 0. 事前準備 (ブランチ作成)
- [x] 1. ヘルパーの修正
  - [x] `app/helpers/book_memos_helper.rb` の `render_book_memo_content` のタグ変換処理を削除し、プレーンテキスト出力 (`simple_format`) に変更する
- [x] 2. ヘルパーテストの修正
  - [x] `spec/helpers/book_memos_helper_spec.rb` のテストケースをプレーンテキスト仕様（タグに変換しない）に変更し、テストを実行・パスさせる
- [x] 3. フォームおよびビューの修正
  - [x] `app/views/books/show.html.erb` から Stimulus 紐付け・ツールバー・データ属性・ヘルプテキストを修正・削除する
  - [x] `app/views/book_memos/edit.html.erb` から Stimulus 紐付け・ツールバー・データ属性・ヘルプテキストを修正・削除する
  - [x] `app/views/book_memos/create.turbo_stream.erb` から Stimulus 紐付け・ツールバー・データ属性・ヘルプテキストを修正・削除する
- [x] 4. コントローラーの削除
  - [x] `app/javascript/controllers/memo_format_controller.js` を削除する
- [x] 5. 全体テストと品質検証
  - [x] `bundle exec rspec` で全テストが通ることを検証
  - [x] `bundle exec rubocop` でコードスタイルに問題がないか検証
- [/] 6. コミット & プッシュ & PR作成
  - [ ] 変更内容をコミットし、ブランチをプッシュして Pull Request を作成する

## 振り返り
*(作業完了後に記述)*
