# タスクリスト

## 🚨 タスク完全完了の原則

**このファイルの全タスクが完了するまで作業を継続すること**

### 必須ルール
- **全てのタスクを`[x]`にすること**
- 「時間の都合により別タスクとして実施予定」は禁止
- 「実装が複雑すぎるため後回し」は禁止
- 未完了タスク（`[ ]`）を残したまま作業を終了しない

---

## フェーズ1: 日本語ロケール設定

- [x] `config/locales/devise.ja.yml` を作成（Devise 日本語メッセージ）
- [x] `config/application.rb` に `config.i18n.default_locale = :ja` を追加

## フェーズ2: カスタムセッションコントローラー

- [x] `app/controllers/users/sessions_controller.rb` を作成
  - [x] `Devise::SessionsController` を継承
  - [x] `after_sign_in_path_for` で books_path（将来）または root_path に遷移
- [x] `config/routes.rb` を更新（`controllers: { sessions: 'users/sessions' }` 追加）

## フェーズ3: ログインビュー

- [x] `app/views/devise/sessions/new.html.erb` を作成
  - [x] メールアドレス・パスワード入力フォーム
  - [x] 「パスワードを忘れた場合」リンク
  - [x] 新規登録画面への切り替えリンク
  - [x] ログインボタン

## フェーズ4: 認証フォームCSS

- [x] `app/assets/stylesheets/auth.css` を作成
  - [x] `.auth-page` レイアウト（中央揃えカード）
  - [x] `.auth-card` コンテナスタイル
  - [x] `.form-group`, `.form-label`, `.form-input` フォームパーツ
  - [x] バリデーションエラー状態のスタイル（`.form-input--error`）

## フェーズ5: テスト

- [x] `spec/requests/user_sessions_spec.rb` を作成
  - [x] GET /users/sign_in → 200 OK
  - [x] POST /users/sign_in（正しい認証情報）→ ログイン成功・リダイレクト
  - [x] POST /users/sign_in（誤った認証情報）→ エラーメッセージ表示
- [x] テスト実行 (`bundle exec rspec spec/requests/user_sessions_spec.rb`) して全 PASS を確認（10例 0失敗）

## フェーズ6: 品質チェック

- [x] `bundle exec rubocop app/controllers/users/sessions_controller.rb` でリントエラーなし
- [x] ~~`bundle exec rubocop app/views/devise/sessions/new.html.erb` でリントエラーなし~~（ERBファイルは対象外）
- [x] `bundle exec rspec` で全テストが通ること（46例 0失敗）

---

## 実装後の振り返り

### 実装完了日
2026-03-15

### 計画と実績の差分

**計画と異なった点**:
- Rails 7 では POST/DELETE のリダイレクトが HTTP 302 ではなく HTTP 303 (See Other) を返す。スペックで `:found` (302) を期待していたが `:see_other` (303) に修正が必要だった。
- ERB ファイルは RuboCop の対象外のため、フェーズ6 のビューリント手順は不要となりスキップ。

**新たに必要になったタスク**:
- なし

### 学んだこと

**技術的な学び**:
- Rails 7 + Turbo は POST/DELETE リダイレクトに HTTP 303 を使う（RFC 7231 準拠）。リクエストスペックで redirect を検証する際は `:see_other` を使うこと。
- Devise の日本語メッセージは `config/locales/devise.ja.yml` を追加し `config.i18n.default_locale = :ja` を設定するだけで適用される。`devise-i18n` gem は不要。
- `after_sign_in_path_for` をオーバーライドする場合は `stored_location_for(resource)` を先に返すことでリダイレクトバック機能を維持できる。
