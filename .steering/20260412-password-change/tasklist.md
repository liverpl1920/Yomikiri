# タスクリスト

## 🚨 タスク完全完了の原則
全タスクが `[x]` になるまで作業を継続すること。

---

## フェーズ1: 実装

- [x] `Users::RegistrationsController` に `update` アクションを追加（パスワード変更後サインアウト→ログイン画面リダイレクト）
- [x] `app/views/devise/registrations/edit.html.erb` を新規作成（W-14 パスワード変更フォーム）

## フェーズ2: テスト

- [x] リクエストスペック `spec/requests/user_password_changes_spec.rb` を作成
  - [x] 未ログインでGET /users/edit → ログインへリダイレクト
  - [x] ログイン済みでGET /users/edit → 200 OK
  - [x] 正しい現在パスワードでPATCH /users → ログインへリダイレクト・サインアウト
  - [x] 誤った現在パスワードでPATCH /users → 422 Unprocessable Content

## フェーズ3: 品質チェック

- [x] RSpec が全て通ることを確認 (`bundle exec rspec`)
- [x] RuboCop エラーがないことを確認 (`bundle exec rubocop`)

---

## 実装後の振り返り

（全タスク完了後に記載）
