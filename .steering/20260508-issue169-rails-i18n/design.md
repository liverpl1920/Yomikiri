# 設計書

## アーキテクチャ概要

Rails の国際化（i18n）フレームワークを活用し、`rails-i18n` gem を追加することで、ActiveRecord・ActiveModel の標準バリデーションメッセージを日本語化する。

既存の設定は以下の通り整っており、gem の追加だけで機能する：
- `config/application.rb` で `config.i18n.default_locale = :ja` が設定済み
- `config/locales/ja.yml` でモデル名・属性名・カスタムメッセージが定義済み

```
Gemfile
  └── rails-i18n ~> 7.0
        └── config/locales/rails/ja.yml (gem内)
              └── activerecord.errors.messages.* (標準エラーメッセージ日本語訳)
```

## コンポーネント設計

### 1. Gemfile 変更

**責務**:
- `rails-i18n` gem を依存関係に追加

**実装の要点**:
- `gem "rails-i18n", "~> 7.0"` を Gemfile の適切な位置に追加（本番環境でも必要なためグローバルスコープ）
- Rails 7.2.x との互換性のため `~> 7.0` を使用

### 2. i18n ロードパス

**責務**:
- gem が提供する日本語ロケールファイルが自動的にロードされる

**実装の要点**:
- `config/application.rb` の `config.i18n.load_path` は `Dir` を使って `config/locales/**/*.yml` を読み込むよう設定済み
- `rails-i18n` gem は Railtie により gem 内の locale ファイルを自動登録するため、追加設定不要

## データフロー

### バリデーションエラーメッセージ表示フロー
```
1. ユーザーがフォームを送信
2. Controller が Model#save / Model#valid? を呼び出す
3. ActiveRecord が バリデーションを実行
4. エラー時、I18n.t("activerecord.errors.messages.blank") 等を参照
5. rails-i18n gem が提供する ja.yml から「を入力してください」を返す
6. View でエラーメッセージが日本語で表示される
```

## エラーハンドリング戦略

gem 追加のみの変更のため、新規エラーハンドリングは不要。

既存の動作への影響確認：
- `config/locales/ja.yml` のカスタムメッセージ（`past_date`, `less_than_or_equal_to` など）は、gem のデフォルト訳より優先されるため影響なし（`ja.yml` の設定が優先される）

## テスト戦略

### 既存テストの確認
- `bundle exec rspec` を実行して全件通過を確認
- 既存のモデルスペック・リクエストスペック・システムスペックが全て通過することを確認

### 手動確認事項
- ユーザー新規登録フォームで必須項目空欄時に日本語エラーが表示されること
- 書籍登録フォームで数値エラーが日本語で表示されること
