# Issue #304 タスクリスト

## ステータス: 進行中

## タスク

- [ ] ブランチ作成: `feature/#304-translator-publisher-search`
- [ ] `app/models/book.rb`: `translator_like` スコープ追加
- [ ] `app/models/book.rb`: `filtered_for_index` に翻訳者絞り込みを追記
- [ ] `app/controllers/books_controller.rb`: `SUGGESTION_FIELDS` に `"translator"` を追加
- [ ] `app/controllers/books_controller.rb`: `normalized_index_search_params` に `:translator` を追加
- [ ] `app/views/books/index.html.erb`: 翻訳者フィールドを追加
- [ ] `spec/models/book_spec.rb`: 翻訳者・出版社絞り込みテスト追加
- [ ] `spec/system/books/search_filter_autocomplete_spec.rb`: 翻訳者・出版社オートコンプリートテスト追加
- [ ] `bundle exec rspec` 実行・確認
- [ ] `bundle exec rubocop` 実行・確認
- [ ] コミット & プッシュ & PR 作成

## 振り返り

（作業完了後に記録）
