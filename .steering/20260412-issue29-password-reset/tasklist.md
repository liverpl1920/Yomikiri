# タスクリスト

## 🚨 タスク完全完了の原則

**このファイルの全タスクが完了するまで作業を継続すること**

---

## フェーズ1: コントローラーとルーティング

- [x] `app/controllers/users/passwords_controller.rb` を作成する
  - [x] `Devise::PasswordsController` を継承
  - [x] `after_resetting_password_path_for` をオーバーライドしてログイン画面へリダイレクト

- [x] `config/routes.rb` を更新する
  - [x] `devise_for` に `passwords: "users/passwords"` を追加

## フェーズ2: ビュー実装

- [x] `app/views/devise/passwords/new.html.erb` を作成する（W-9: パスワード再設定リクエスト画面）
  - [x] auth-cardスタイルを踏襲
  - [x] メールアドレス入力フォーム
  - [x] 「再設定メールを送信」ボタン
  - [x] エラー表示
  - [x] 「ログイン画面に戻る」リンク

- [x] `app/views/devise/passwords/edit.html.erb` を作成する（W-14: パスワード変更画面）
  - [x] auth-cardスタイルを踏襲
  - [x] 新パスワード・確認用パスワード入力フォーム
  - [x] `reset_password_token` hidden field
  - [x] エラー表示
  - [x] 「ログイン画面に戻る」リンク

## フェーズ3: メール設定

- [x] `config/environments/production.rb` にActionMailer/SendGrid SMTP設定を追加する
  - [x] `config.action_mailer.delivery_method = :smtp` を設定
  - [x] SendGrid SMTP設定（`ENV.fetch("SENDGRID_API_KEY")`）を追加
  - [x] `config.action_mailer.default_url_options` を設定

- [x] `config/initializers/devise.rb` の `config.mailer_sender` を更新する

## フェーズ4: テスト実装

- [x] `spec/requests/passwords_spec.rb` を作成する
  - [x] GET `/users/password/new` → 200レスポンス確認
  - [x] POST `/users/password` with valid email → リダイレクト確認
  - [x] POST `/users/password` with invalid email → エラー確認

## フェーズ5: 品質チェック

- [x] RSpecを全て実行して通過することを確認
  - [x] `bundle exec rspec`
- [x] RuboCopを実行してエラーがないことを確認
  - [x] `bundle exec rubocop`

---

## 実装後の振り返り

### 実装完了日
2026-04-12

### 計画と実績の差分

**計画と異なった点**:
- 計画通りに全タスクを実装完了。差分なし。

### 学んだこと
- Deviseの `:recoverable` モジュールはUserモデルにすでに含まれており、ビューとカスタムコントローラーを追加するだけでパスワード再設定フロー全体が動く。
- `after_resetting_password_path_for` をオーバーライドすることで、Deviseのデフォルト（ログイン状態でのリダイレクト）から、ログイン画面へのリダイレクトに変更できる。
- production.rbでの `ENV.fetch("SENDGRID_API_KEY")` を使用することでキーが未設定の場合にKeyErrorが発生し、早期に設定漏れを検知できる。
- `config.action_mailer.default_url_options` は各環境ファイルで設定する必要がある（development.rbにはすでに設定されていた）。

### 次回への改善提案
- SendGridのAPIキーをRenderへ実際に登録する作業（インフラ側の設定）を実施すること。
- `APP_HOST` 環境変数もRenderへ登録することで `default_url_options` のホスト名が正しく設定される。
- カスタムDeviseメールテンプレートを将来的に作成して、デザインの統一感を出すとよい。
