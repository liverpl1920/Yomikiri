# 設計: ユーザーログアウト機能

## 実装方針

Devise の標準ログアウト機能をベースに、リダイレクト先をTOPページ（root_path）に明示的に設定する。

## 変更ファイル

### 1. `app/controllers/users/sessions_controller.rb`

`after_sign_out_path_for` メソッドを追加し、ログアウト後のリダイレクト先を明示的に `root_path` に設定する。

Devise のデフォルトでも `root_path` にリダイレクトされるが、明示することで仕様として固定する。

```ruby
# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    private

    def after_sign_in_path_for(resource)
      # Issue #15（積読一覧）実装後は books_path に変更する
      stored_location_for(resource) || root_path
    end

    def after_sign_out_path_for(_resource_or_scope)
      root_path
    end
  end
end
```

### 2. `spec/requests/user_sessions_spec.rb`

既存のログアウトスペックにリダイレクト先の検証を追加する。

## 技術仕様

### ルーティング

Devise が自動生成する `destroy_user_session_path` (DELETE /users/sign_out) を使用。既存 `routes.rb` の変更は不要。

### HTTPメソッド

DELETE メソッドを使用（CSRF保護のため GET は不可）。ビューでは `button_to ... method: :delete` を使用済み。

### フラッシュメッセージ

Devise のデフォルトフラッシュメッセージ（en.yml / ja.yml）を使用。

## 設計判断

| 判断 | 理由 |
|------|------|
| `after_sign_out_path_for` を追加 | デフォルト動作でもrootへ遷移するが、仕様として明示するため |
| `root_path` へのリダイレクト | Issue要件「ログアウト後にTOPページへリダイレクト」に準拠 |
| 新たなコントローラー追加なし | Deviseの標準機能で賄えるため |
