# タスクリスト: Issue #376 書籍詳細画面 前後ナビゲーション

## タスク

- [x] ブランチ作成 (`feature/#376-book-nav`)
- [x] `app/models/book.rb` に `prev_book_by_id` / `next_book_by_id` を追加
- [x] `spec/models/book_spec.rb` に対応するテストを追加
- [x] `app/views/books/show.html.erb` にナビゲーションブロックを追加
- [x] `app/assets/stylesheets/books.css` にスタイルを追加
- [x] `bundle exec rspec` で全テスト通過確認
- [x] `bundle exec rubocop` でリント確認・修正
- [x] コミット & プッシュ & PR 作成

## 振り返り

- 既存の `previous_book` との混同を避けるためのメソッド命名規則や、前後書籍が存在しない場合の非活性表示によるアクセシビリティ考慮など、設計意図に沿った実装が完了しました。
- システムテストを追加し、端の書籍での動作や中間の書籍での遷移が正しく機能することを実証できました。

