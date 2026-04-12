# 設計書

## アーキテクチャ概要

Rails標準のMVCパターンとDevise認証を使用する。
`edit_user_registration_path` (`GET /users/edit`) を W-14 パスワード変更専用画面として実装。

```
W-8 マイページ (/mypage)
  ↓ パスワードを変更するリンク (edit_user_registration_path)
W-14 パスワード変更 (/users/edit)
  ↓ PATCH /users (password change)
  ↓ 成功: sign_out + redirect
W-3 ログイン (/users/sign_in)
```

## コンポーネント設計

### 1. Users::RegistrationsController（修正）

**責務**:
- `update` アクションをオーバーライドしてパスワード変更後のサインアウト・リダイレクトを制御する

**実装の要点**:
- `current_user.update_with_password(account_update_params)` でパスワード検証と更新
- 更新成功時: `sign_out current_user` → `redirect_to new_user_session_path`
- 更新失敗時: `render :edit, status: :unprocessable_entity`
- `clean_up_passwords resource` でパスワードフィールドをクリア（再表示時の安全性）

### 2. `app/views/devise/registrations/edit.html.erb`（新規作成）

**責務**:
- W-14 パスワード変更フォームを表示する

**実装の要点**:
- 既存の `auth.css` のクラスを使用（`auth-page`, `auth-card__*`, `form-group`, etc.）
- フィールド: `current_password`, `password`, `password_confirmation`
- エラー表示: Devise デバイスエラーメッセージ
- マイページへの戻りリンク (`mypage_path`)

## データフロー

### パスワード変更フロー
```
1. ユーザーが /users/edit にアクセス (GET)
   → Users::RegistrationsController#edit (Devise デフォルト)
   → app/views/devise/registrations/edit.html.erb を表示
2. フォーム入力・送信 (PATCH /users)
   → Users::RegistrationsController#update
   → resource.update_with_password(params)
     - 成功: sign_out → redirect_to new_user_session_path
     - 失敗: clean_up_passwords → render :edit (422)
```

## テスト戦略

### リクエストスペック (`spec/requests/user_password_changes_spec.rb`)
- 未ログイン: GET /users/edit → ログイン画面へリダイレクト
- ログイン済み: GET /users/edit → 200 OK
- パスワード変更成功: PATCH /users → ログイン画面へリダイレクト
- 誤った現在パスワード: PATCH /users → 422

### システムスペック (`spec/system/auth/password_change_spec.rb`)
- 正しい現在パスワードで変更できる
- 変更後にログイン画面へリダイレクトされる
- 誤った現在パスワードでエラーが表示される
