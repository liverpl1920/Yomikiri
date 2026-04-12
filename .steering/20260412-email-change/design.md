# 設計

## 実装アプローチ

### メールアドレス変更確認フロー

Devise の `:confirmable` モジュール（`reconfirmable: true`）を活用する。

#### フロー概要

```
[W-8 マイページ]
    ↓ 「メールアドレスを変更する」リンク
[W-15 メールアドレス変更フォーム]
    ↓ 現在のパスワード + 新しいメールアドレスを入力して送信
[確認メール送信完了ページ / マイページにフラッシュ]
    ↓ 新メールアドレスに届いたリンクをクリック
[W-17 メールアドレス変更完了画面]
    ↓ 「ログイン画面へ」ボタン
[W-3 ログイン画面]
```

### DBスキーマ変更

`users` テーブルに以下の列を追加：

| 列名 | 型 | 説明 |
|------|---|------|
| `confirmation_token` | string | 確認メールのトークン |
| `confirmed_at` | datetime | 確認日時 |
| `confirmation_sent_at` | datetime | 確認メール送信日時 |
| `unconfirmed_email` | string | 未確認の新メールアドレス（reconfirmable 用） |

既存ユーザーは `confirmed_at = created_at` で初期化する。

### モデル変更（User）

```ruby
devise :database_authenticatable, :registerable,
       :recoverable, :rememberable, :validatable, :confirmable
```

### コントローラー設計

#### Users::EmailChangesController

| アクション | HTTP | パス | 説明 |
|-----------|------|------|------|
| `edit` | GET | `/users/email_change/edit` | W-15 フォーム表示 |
| `update` | PATCH | `/users/email_change` | 変更処理（パスワード検証＋確認メール送信） |
| `complete` | GET | `/email_change/complete` | W-17 変更完了画面 |

#### Users::ConfirmationsController

- Devise の `ConfirmationsController` を継承
- `after_confirmation_path_for` をオーバーライドし、W-17 にリダイレクト
- 確認完了後にサインアウトする

### ルーティング

```ruby
devise_for :users, controllers: {
  sessions: "users/sessions",
  registrations: "users/registrations",
  passwords: "users/passwords",
  confirmations: "users/confirmations"
}

resource :email_change, only: [:edit, :update], controller: 'users/email_changes'
get 'email_change/complete', to: 'users/email_changes#complete', as: :email_change_complete
```

### ビュー設計

| ファイル | 画面 | 説明 |
|---------|------|------|
| `app/views/users/email_changes/edit.html.erb` | W-15 | メールアドレス変更フォーム |
| `app/views/users/email_changes/complete.html.erb` | W-17 | 変更完了画面 |
| `app/views/devise/mailer/confirmation_instructions.html.erb` | W-16 メール | 確認メールのテンプレート |

## セキュリティ考慮事項

- `before_action :authenticate_user!` でログイン必須
- `current_user.valid_password?(current_password)` で本人確認
- Devise の `paranoid` モードでエラーメッセージを統一
- CSRF 保護は Rails デフォルトで対応
