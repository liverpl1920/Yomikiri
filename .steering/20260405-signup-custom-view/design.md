# 設計: Sign Up画面カスタムデザイン適用

## 実装アプローチ

### ファイル構成

```
app/views/devise/registrations/
  new.html.erb   ← 新規作成（メイン実装）

app/controllers/users/
  registrations_controller.rb  ← nickname permit追加
```

### ビュー設計

ログイン画面 (`app/views/devise/sessions/new.html.erb`) のパターンに倣い、
以下の構造で実装する：

```erb
<% content_for :title, "新規登録 | Yomikiri" %>

<div class="auth-page">
  <div class="auth-card">
    <!-- ヘッダー部分 -->
    <div class="auth-card__header">
      ロゴ + タイトル + サブタイトル
    </div>

    <!-- フォーム部分 -->
    form_for 使用
    - メールアドレス（必須）
    - ニックネーム（任意、最大50文字）
    - パスワード（必須、6文字以上）
    - パスワード確認（必須）
    - 送信ボタン「登録する」

    <!-- フッター部分 -->
    - ログインページへのリンク
  </div>
</div>
```

### コントローラ設計

Deviseのstrong parameters customizationとして `configure_permitted_parameters` を使う方法と、
`sign_up_params` をオーバーライドする方法がある。

Deviseの標準的なアプローチとして `before_action` で `configure_permitted_parameters` を使う。

```ruby
before_action :configure_sign_up_params, only: [:create]

def configure_sign_up_params
  devise_parameter_sanitizer.permit(:sign_up, keys: [:nickname])
end
```

### エラー表示

Deviseのバリデーションエラーは `resource.errors` として渡される。
ログイン画面と同様の方法でエラー表示を実装する。
shared/_error_messages.html.erb が存在すれば流用する。

## 既存パターンとの整合性

- CSS クラス名はログイン画面に完全準拠
- form_for + resource パターン（Deviseの標準）
- 日本語ラベル・プレースホルダー統一
