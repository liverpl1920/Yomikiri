# タスクリスト

## 🚨 タスク完全完了の原則

**このファイルの全タスクが完了するまで作業を継続すること**

---

## フェーズ1: DB・モデル変更

- [x] DB Migration 作成（confirmable カラム追加）
  - [x] `confirmation_token`, `confirmed_at`, `confirmation_sent_at`, `unconfirmed_email` を追加
  - [x] 既存ユーザーの `confirmed_at = created_at` を設定する
- [x] User モデルに `:confirmable` を追加

## フェーズ2: ルーティング

- [x] `confirmations: "users/confirmations"` を devise_for に追加
- [x] `resource :email_change` と完了ページルート追加

## フェーズ3: コントローラー

- [x] `Users::EmailChangesController` を作成
  - [x] `edit` アクション（W-15 フォーム表示）
  - [x] `update` アクション（パスワード検証＋ reconfirmable メール送信）
  - [x] `complete` アクション（W-17 表示）
- [x] `Users::ConfirmationsController` を作成
  - [x] `after_confirmation_path_for` をオーバーライド（W-17 へリダイレクト＋サインアウト）

## フェーズ4: ビュー

- [x] `app/views/users/email_changes/edit.html.erb`（W-15）
- [x] `app/views/users/email_changes/complete.html.erb`（W-17）
- [x] `app/views/devise/mailer/confirmation_instructions.html.erb`（確認メール）
- [x] マイページ（W-8）に「メールアドレスを変更する」リンクを追加

## フェーズ5: I18n

- [x] `config/locales/ja.yml` にメールアドレス変更関連の文字列を追加

## フェーズ6: テスト

- [x] `spec/requests/email_changes_spec.rb` を作成
  - [x] GET /users/email_change/edit（未ログイン・ログイン済み）
  - [x] PATCH /users/email_change（正常・パスワード不一致・メール重複）
  - [x] GET /email_change/complete（W-17 表示）

## フェーズ7: 品質チェック

- [x] `bundle exec rspec` が全て通ること（263 examples, 0 failures）
- [x] `bundle exec rubocop` にエラーがないこと

---

## 実装後の振り返り

**実装完了日:** 2026/04/12

**計画と実績の差分:**
- RegistrationsController の `build_resource` をオーバーライドして `skip_confirmation!` を呼ぶことで、新規登録時は確認メール不要・既存ユーザーのメールアドレス変更時のみ確認フローを通す設計を実現した
- spec/factories/users.rb に `confirmed_at { Time.current }` を追加する必要があった（想定通り）

**学んだこと:**
- Devise `:confirmable` を後から追加する場合、既存ユーザーを `confirmed_at = created_at` で初期化することで、既存ユーザーのロックアウトを防げる
- `config.reconfirmable = true` はメールアドレス変更時のみ再確認を要求する設定。新規登録でもデフォルトで確認を求めるため、既存の登録フローを壊さないよう `skip_confirmation!` が必要

**次回への改善提案:**
- メールアドレス変更元へのセキュリティ通知メールを追加することでさらにセキュアになる（本リリース向け）
