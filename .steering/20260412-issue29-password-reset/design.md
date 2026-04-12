# 設計書

## アーキテクチャ概要

Rails標準のMVCパターンに従い、Deviseの `:recoverable` モジュールを活用する。
カスタムPasswordsコントローラーを追加し、既存の認証系ビューのスタイル（auth-card）を踏襲する。

```
[W-3: ログイン画面]
  └─ 「パスワードを忘れた場合」リンク
       └─ [W-9: パスワード再設定リクエスト画面]
            └─ メールアドレス入力 → 送信
                 └─ Devise::Mailer でメール送信
                      └─ [W-11: Gmail メール]
                           └─ メール内リンク
                                └─ [W-14: パスワード変更画面]
                                     └─ 新パスワード入力 → 変更完了
                                          └─ [W-3: ログイン画面] へリダイレクト
```

## コンポーネント設計

### 1. Users::PasswordsController

**責務**:
- Devise::PasswordsControllerを継承
- パスワード変更後のリダイレクト先（ログイン画面）をカスタマイズ

**実装の要点**:
- `after_resetting_password_path_for` をオーバーライドしてログイン画面へリダイレクト
- `app/controllers/users/passwords_controller.rb` に配置
- 既存の `sessions_controller.rb` / `registrations_controller.rb` と同じ構造

### 2. パスワード再設定リクエストビュー（W-9）

**責務**:
- メールアドレス入力フォームを表示
- Deviseのフォームヘルパーを使用して `user_password_path` へPOST

**実装の要点**:
- `app/views/devise/passwords/new.html.erb`
- 既存のauth-cardスタイルを踏襲（sessions/new.html.erbと同じCSS設計）
- エラー表示を含む
- 「ログイン画面に戻る」リンクを配置

### 3. パスワード変更ビュー（W-14）

**責務**:
- 新しいパスワードと確認用パスワードの入力フォームを表示
- `reset_password_token` をhidden fieldで保持

**実装の要点**:
- `app/views/devise/passwords/edit.html.erb`
- Deviseの標準ビューを参照しつつ、auth-cardスタイルで実装
- エラー表示を含む

### 4. ルーティング更新

**責務**:
- `devise_for` に `:passwords` カスタムコントローラーを追加

**実装の要点**:
- `config/routes.rb` の `devise_for` に `passwords: "users/passwords"` を追加

### 5. ActionMailer/SendGrid設定（production.rb）

**責務**:
- 本番環境でSendGrid経由でメール送信できるようにする

**実装の要点**:
- `config/environments/production.rb` にSMTP設定を追加
- `SENDGRID_API_KEY` 環境変数を利用（`ENV.fetch`で安全に取得）
- Rails 7.2の `config.action_mailer.default_url_options` も設定

### 6. Devise mailer_sender 設定

**実装の要点**:
- `config/initializers/devise.rb` の `config.mailer_sender` をサービス用アドレスに変更

## データフロー

### パスワード再設定フロー
```
1. ユーザーがW-9でメールアドレスを入力してPOST
2. Devise::PasswordsController#create がメールアドレス検索
3. Devise::Mailer がリセットトークン付きメールを送信
4. ユーザーがメール内のリンクをクリック → W-14へ GET
5. ユーザーが新パスワードを入力してPOST
6. Devise::PasswordsController#update がパスワードを更新
7. Users::PasswordsController#after_resetting_password_path_for がW-3へリダイレクト
```

## エラーハンドリング戦略

- 未登録メールアドレス入力時: Deviseデフォルトのフラッシュメッセージを表示
- パスワード不一致時: Deviseデフォルトのバリデーションエラーを表示
- 期限切れトークン: Deviseデフォルトのエラーメッセージを表示（devise.ja.ymlに翻訳済み）

## テスト戦略

### リクエストスペック
- `spec/requests/passwords_spec.rb`
- GET `/users/password/new` → 200レスポンス
- POST `/users/password` with valid email → リダイレクト
- POST `/users/password` with invalid email → 422レスポンス

## 依存ライブラリ

新規追加なし。Deviseの `:recoverable` モジュールは既にUserモデルに設定済み。

## ディレクトリ構造

```
app/
  controllers/
    users/
      passwords_controller.rb   ← 新規
  views/
    devise/
      passwords/
        new.html.erb            ← 新規（W-9）
        edit.html.erb           ← 新規（W-14）
config/
  routes.rb                     ← 変更（passwords controller追加）
  environments/
    production.rb               ← 変更（SendGrid SMTP設定追加）
  initializers/
    devise.rb                   ← 変更（mailer_sender更新）
spec/
  requests/
    passwords_spec.rb           ← 新規
```

## 実装の順序

1. `Users::PasswordsController` 作成
2. ルーティング更新
3. W-9ビュー（passwords/new.html.erb）作成
4. W-14ビュー（passwords/edit.html.erb）作成
5. production.rb に ActionMailer/SendGrid設定追加
6. devise.rb の mailer_sender 更新
7. リクエストスペック作成
8. RSpec / RuboCop 実行
