# タスクリスト (Issue #291)

## 準備
- [x] 課題用ブランチの作成 (`feature/#291-review-display-fix`)

## 設計・計画
- [x] 変更内容の確認と計画の承認を得る

## 実装
- [x] 詳細画面 (`app/views/books/show.html.erb`) に `meta name="turbo-cache-control" content="no-cache"` を追加
- [x] お祝いモーダルのフォームに `hidden_field_tag :redirect_to, 'index'` を追加
- [x] コントローラー (`app/controllers/books_controller.rb`) の `update_review` アクションのリダイレクト先を制御し、`status: :see_other` を追加

## テスト修正・追加
- [x] リクエストスペック (`spec/requests/books_spec.rb`) を修正し、新しいリダイレクト先の挙動を確認するテストを追加
- [x] システムスペック (`spec/system/books/review_spec.rb`) に詳細画面での評価・感想更新のテストを追加し、手動リロードなしで最新 of 最新の評価が反映されることを確認

## 検証
- [x] RSpec でテストが通ることを確認 (`bundle exec rspec spec/system/books/review_spec.rb spec/requests/books_spec.rb`)
- [x] 全体の RSpec テストを実行 (`bundle exec rspec`)
- [x] RuboCop の実行と修正 (`bundle exec rubocop`)

## 完了・報告
- [x] コミット
- [ ] プッシュ & プルリクエスト作成 (ユーザーの合意待ち)
