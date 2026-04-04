# 設計: Issue #83 - 新規登録後リダイレクト先修正

## 実装アプローチ

### 1. RegistrationsController の新規作成

`app/controllers/users/sessions_controller.rb` と同じパターンを踏襲し、
`Devise::RegistrationsController` を継承した `Users::RegistrationsController` を作成する。

```ruby
# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    private

    def after_sign_up_path_for(resource)
      books_path
    end
  end
end
```

### 2. routes.rb の更新

`devise_for` の `controllers` オプションに `registrations: "users/registrations"` を追加する。

```ruby
devise_for :users, controllers: {
  sessions: "users/sessions",
  registrations: "users/registrations"
}
```

### 3. リクエストスペックの追加

`spec/requests/user_registrations_spec.rb` を新規作成し、
`POST /users` （サインアップ）後に `/books` へリダイレクトされることを確認するテストを追加する。

## 設計上の考慮事項

- `after_sign_up_path_for` は Devise が提供するフックメソッド。
  オーバーライドするだけで登録後のリダイレクト先を変更できる。
- `after_inactive_sign_up_path_for` は今回実装しない（メール確認が有効でないため）。
- 最小限の変更で修正できるバグフィックスであり、既存機能への影響はない。
