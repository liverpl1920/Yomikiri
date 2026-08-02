# 設計書

## アーキテクチャ概要

本変更は Rails の ActionMailer 設定および Devise 設定の修正です。
環境変数 `MAILER_SENDER` から送信元アドレスを動的に取得するようにし、環境変数が未設定の場合はデフォルトとして `noreply@yomikiri-app.com`（Issue #393 で設定されたドメインに基づく）を使用します。

## コンポーネント設計

### 1. ApplicationMailer (`app/mailers/application_mailer.rb`)

**責務**:
- Yomikiri アプリケーション全体で送信される汎用メールの基底クラス。

**実装の要点**:
- `default from:` に `ENV.fetch("MAILER_SENDER", "noreply@yomikiri-app.com")` を設定する。

### 2. Devise Configuration (`config/initializers/devise.rb`)

**責務**:
- ユーザー認証およびパスワードリセットなどのシステムメール送信設定。

**実装の要点**:
- `config.mailer_sender` に `ENV.fetch("MAILER_SENDER", "noreply@yomikiri-app.com")` を設定する。

### 3. 環境変数テンプレート (`.env.example`)

**責務**:
- 開発者に対して設定可能な環境変数を例示する。

**実装の要点**:
- `MAILER_SENDER` を追加し、送信元アドレスを指定できるようにする。

## テスト戦略

### ユニットテスト (`spec/mailers/reading_report_mailer_spec.rb`)
- 各レポートメール（`weekly_report` 等）の `from` が設定値になっていることをテストする。
- 環境変数 `MAILER_SENDER` を一時的に変更した際に、送信元アドレスがそれに追従することを検証するテストケースを追加する。

### Devise メーラー設定のテスト
- Deviseの送信元アドレス設定に関するテスト（Deviseのメーラー設定が正しく行われていることを確認するテスト）を追加する。
- または、`config/initializers/devise.rb` の設定値を `Devise.mailer_sender` で取得できることを確認するテストを `spec/initializers/devise_spec.rb` などを追加して検証する。

## ディレクトリ構造

```
app/
  mailers/
    application_mailer.rb (MODIFY)
config/
  initializers/
    devise.rb (MODIFY)
.env.example (MODIFY)
spec/
  mailers/
    reading_report_mailer_spec.rb (MODIFY)
  initializers/
    devise_spec.rb (NEW - Devise.mailer_sender を検証するテスト)
```

## 実装の順序

1. `spec/mailers/reading_report_mailer_spec.rb` と `spec/initializers/devise_spec.rb` に、送信元アドレスに関するテスト（期待する動作を定義したテスト）を追加する。（テスト駆動開発的に、まずは失敗することを確認する）
2. `app/mailers/application_mailer.rb` を修正する。
3. `config/initializers/devise.rb` を修正する。
4. `.env.example` に設定項目を追加する。
5. テストを実行して成功することを確認する。
