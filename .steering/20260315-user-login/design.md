# 設計書

## アーキテクチャ概要

Devise の標準的な Sessions コントローラーを継承したカスタムコントローラーを使用。
ビューは Devise のデフォルトを使わず、プロジェクトの BEM デザインシステムに合わせた独自ビューを作成する。

```
Browser
  └── GET /users/sign_in
        └── Users::SessionsController#new
              └── app/views/devise/sessions/new.html.erb
                    └── POSTフォーム→ /users/sign_in
                          └── Users::SessionsController#create (Devise 標準)
                                ├── 認証成功: after_sign_in_path_for → books_path (将来実装)
                                └── 認証失敗: フラッシュメッセージ + 再描画
```

## コンポーネント設計

### 1. Users::SessionsController

**責務**:
- Devise::SessionsController を継承
- `after_sign_in_path_for` をオーバーライドして books_path へリダイレクト

**実装の要点**:
- `app/controllers/users/sessions_controller.rb` に配置
- routes.rb で `controllers: { sessions: 'users/sessions' }` を指定

### 2. ログインビュー（app/views/devise/sessions/new.html.erb）

**责務**:
- メールアドレス・パスワードの入力フォーム
- 「パスワードを忘れた場合」リンク
- 新規登録画面へのリンク

**実装の要点**:
- Devise の `resource` ヘルパーを使用（`f.email_field :email` 等）
- フォーム全体を `.auth-card` でラップ
- エラーは application.html.erb の flash で表示（既存実装を流用）

### 3. 日本語ロケール（config/locales/devise.ja.yml）

**責務**:
- Devise のフラッシュメッセージを日本語で提供

**実装の要点**:
- `config.i18n.default_locale = :ja` を application.rb に追加
- devise.ja.yml に認証失敗・成功メッセージを定義

### 4. 認証フォームCSS（app/assets/stylesheets/auth.css）

**责務**:
- ログイン・新規登録ページ共通のフォームスタイル

**実装の要点**:
- `.auth-page`, `.auth-card`, `.form-group`, `.form-label`, `.form-input` クラスを定義
- CSS カスタムプロパティ（`--color-primary` 等）を使用
- BEM 命名規則に従う

## データフロー

### ログイン成功フロー
```
1. ユーザーが /users/sign_in にアクセス
2. SessionsController#new → ログインフォーム表示
3. フォーム送信 → SessionsController#create
4. Devise が email + password で認証
5. after_sign_in_path_for → books_path (TODO: 実装後）/ root_path (暫定)
6. リダイレクト＋「ログインしました」フラッシュメッセージ
```

### ログイン失敗フロー
```
1. フォーム送信 → SessionsController#create
2. Devise が認証失敗を検知
3. フラッシュメッセージ「メールアドレスまたはパスワードが正しくありません」
4. ログインフォームを再描画
```

## テスト戦略

### リクエストスペック（spec/requests/user_sessions_spec.rb）
- GET /users/sign_in → 200 OK、フォームが表示される
- POST /users/sign_in（正しい認証情報）→ 302 リダイレクト（root または books）
- POST /users/sign_in（誤った認証情報）→ 200、エラーメッセージ表示
- ログイン後にログインページへアクセス → リダイレクト

## ディレクトリ構造

```
追加・変更されるファイル:

config/application.rb               # config.i18n.default_locale = :ja 追加
config/locales/devise.ja.yml        # 新規作成（日本語メッセージ）
app/controllers/users/
  └── sessions_controller.rb        # 新規作成（カスタム sessions）
app/views/devise/sessions/
  └── new.html.erb                  # 新規作成（ログインフォーム）
app/assets/stylesheets/
  └── auth.css                      # 新規作成（認証フォームCSS）
config/routes.rb                    # devise_for に controllers オプション追加
spec/requests/
  └── user_sessions_spec.rb         # 新規作成（リクエストスペック）
```

## セキュリティ考慮事項

- Devise が CSRF トークンを自動挿入（`<%= csrf_meta_tags %>`）
- パスワードは bcrypt でハッシュ化（Devise 標準）
- メールアドレス・パスワードのどちらが誤りかをユーザーに伝えない（セキュリティベストプラクティス）
- `config.paranoid = true` の検討（今回は未設定のまま）

## 将来の拡張性

- Issue #29 でパスワード再設定フォームを実装後、「パスワードを忘れた場合」リンクが機能する
- Issue #14 で books_path が実装されると after_sign_in_path_for が積読一覧に遷移する
