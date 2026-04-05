# タスクリスト: Issue #83 - 新規登録後リダイレクト先修正

## 🚨 タスク完全完了の原則

**このファイルの全タスクが完了するまで作業を継続すること**

---

## フェーズ1: コントローラー作成

- [x] `app/controllers/users/registrations_controller.rb` を新規作成
  - [x] `Devise::RegistrationsController` を継承
  - [x] `after_sign_up_path_for` を実装して `books_path` を返す

## フェーズ2: ルーティング更新

- [x] `config/routes.rb` の `devise_for` に `registrations: "users/registrations"` を追加

## フェーズ3: テスト追加

- [x] `spec/requests/user_registrations_spec.rb` を新規作成
  - [x] `POST /users` で新規登録成功後に `books_path` へリダイレクトされることを確認するテストを追加

## フェーズ4: 品質チェック

- [x] RSpec を全件実行して通過を確認
  - [x] `bundle exec rspec` → 176 examples, 0 failures
- [x] RuboCop を実行してエラーがないことを確認
  - [x] `bundle exec rubocop` → 45 files inspected, no offenses detected
