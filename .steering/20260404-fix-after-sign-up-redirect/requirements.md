# 要求仕様: Issue #83 - 新規登録後リダイレクト先修正

## 概要

新規ユーザー登録（サインアップ）完了後、積読一覧画面（`/books`）へ遷移すべきところ、
Top画面（`/`）にリダイレクトされてしまうバグを修正する。

## 背景・原因

- `app/controllers/users/sessions_controller.rb` には `after_sign_in_path_for` が実装されており、
  ログイン後は `books_path` へ遷移するよう設定されている。
- 新規登録後のリダイレクト先を制御する `after_sign_up_path_for` が未実装のため、
  Deviseのデフォルト動作により `root_path`（Top画面）へ遷移してしまう。
- `Users::RegistrationsController` 自体が存在しない。

## 期待する動作

新規登録後 → 積読一覧画面（`/books`）へ遷移

## 実際の動作（修正前）

新規登録後 → Top画面（`/`）へ遷移

## 修正方針

1. `app/controllers/users/registrations_controller.rb` を新規作成し、`after_sign_up_path_for` を実装
2. `config/routes.rb` の `devise_for` に `registrations: "users/registrations"` を追加
3. 新規登録後のリダイレクトを確認するリクエストスペックを追加

## 影響範囲

- `config/routes.rb`（更新）
- `app/controllers/users/registrations_controller.rb`（新規作成）
- `spec/requests/user_registrations_spec.rb`（新規作成）
