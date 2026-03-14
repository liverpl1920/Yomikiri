# Issue #12: 設計方針

## アーキテクチャ設計

### 1. Devise セットアップ

#### 1.1 devise:install
- `rails generate devise:install` で設定ファイルを生成
- `config/initializers/devise.rb` が作成される
- `config/locales/devise.en.yml` (日本語化は後続 Issue で対応)

#### 1.2 User モデル
- `rails generate devise User` で User モデル + マイグレーションを生成
- モデルは `app/models/user.rb` に配置
- functional-design.md のスキーマに従い `nickname` カラムを追加するマイグレーションを作成

#### 1.3 routes.rb
```ruby
devise_for :users
```

### 2. 共通レイアウト構成

```
app/views/
  layouts/
    application.html.erb    ← ヘッダー・フッターを yield で組み込む
  shared/
    _header.html.erb        ← ログイン状態に応じた条件分岐を含む
    _footer.html.erb        ← 共通フッター
```

### 3. ヘッダーの設計

```erb
<%# app/views/shared/_header.html.erb %>
<header class="site-header">
  <div class="container site-header__inner">
    <%= link_to 'Yomikiri', root_path, class: 'site-header__logo' %>
    <% if user_signed_in? %>
      <%# ログイン済みヘッダー（ユーザーアイコン + ドロップダウン） %>
    <% else %>
      <%# ゲストヘッダー（新規登録 + ログイン） %>
    <% end %>
  </div>
</header>
```

### 4. ドロップダウンの実装

Stimulus Controller を使って JavaScript でドロップダウンを制御する。

```javascript
// app/javascript/controllers/dropdown_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggle() {
    this.menuTarget.classList.toggle("dropdown__menu--open")
  }

  // 外側クリックで閉じる
  close(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.remove("dropdown__menu--open")
    }
  }
}
```

### 5. CSS 設計（BEM）

```
.site-header             ← ヘッダーのブロック
.site-header__inner      ← 内側レイアウト
.site-header__logo       ← ロゴ
.site-header__nav        ← ナビゲーション
.site-header__user       ← ユーザーアイコンエリア

.dropdown                ← ドロップダウンブロック
.dropdown__trigger       ← トリガーボタン
.dropdown__menu          ← メニューリスト
.dropdown__menu--open    ← 開いている状態（JS で付与）
.dropdown__item          ← 各メニュー項目

.site-footer             ← フッターのブロック
.site-footer__inner      ← 内側レイアウト
.site-footer__logo       ← フッターロゴ
.site-footer__copy       ← コピーライト
```

### 6. TOPページの変更

- `top/index.html.erb` に埋め込まれた `<header>` と `<footer>` を削除
- 共通レイアウト（`application.html.erb`）の `_header` と `_footer` に統合

### 7. application.html.erb の変更

```erb
<body>
  <%= render 'shared/header' %>
  <main>
    <%= yield %>
  </main>
  <%= render 'shared/footer' %>
</body>
```

## テスト方針

- RSpec Request Spec: ルーティングが正しく設定されているか確認
- RSpec System Spec: 未ログイン時・ログイン時のヘッダー表示切り替えをテスト
