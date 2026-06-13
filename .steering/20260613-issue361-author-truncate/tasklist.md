# Issue #361 タスクリスト：著者複数人の省略表示

## タスク

- [x] ステアリングファイル作成（requirements.md, design.md, tasklist.md）
- [x] ブランチ作成（`feature/#361-author-truncate`）
- [/] `BooksHelper` に `book_author_display` メソッドを追加
- [ ] `books/index.html.erb` の著者表示を `book_author_display(book)` に変更
- [ ] `spec/helpers/books_helper_spec.rb` にテストを追加
- [ ] `bundle exec rspec spec/helpers/books_helper_spec.rb` でテスト実行
- [ ] `bundle exec rspec` で全テスト実行
- [ ] `bundle exec rubocop` で Lint 確認
- [ ] コミット・プッシュ・PR 作成

## 振り返り

（完了後に記載）
