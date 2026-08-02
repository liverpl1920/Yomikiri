# 要求内容

## 概要

読書レポート送信用メーラー（ApplicationMailer および ReadingReportMailer）の送信元アドレス（default from）がデフォルトの `from@example.com` のままになっているため、認証用メール（Devise）と同様に、設定されたドメイン `yomikiri-app.com` を用いた適切な送信元アドレス `noreply@yomikiri-app.com` に統一します。また、環境変数 `MAILER_SENDER` から動的に取得できるように修正します。

## 背景

- 現在の読書レポート送信用メールの送信元が `from@example.com` になっており、本番環境での信頼性や到達率に悪影響を及ぼす。
- 送信元アドレスを環境変数等から動的に設定できるようにすることで、開発環境と本番環境での切り替えを容易にする。
- 本番ドメインとして `yomikiri-app.com` が設定されたため、送信元アドレスのデフォルト値を `noreply@yomikiri-app.com` に統一する。

## 実装対象の機能

### 1. メーラーの送信元アドレス設定の環境変数化と統一
- `ApplicationMailer` の `default from` を環境変数 `MAILER_SENDER` が存在する場合はその値を、存在しない場合はデフォルトとして `noreply@yomikiri-app.com` を使用するように変更する。
- `config/initializers/devise.rb` の `config.mailer_sender` にも同様に、環境変数 `MAILER_SENDER` を使用し、デフォルト値として `noreply@yomikiri-app.com` を使用するように変更する。

### 2. 環境変数設定用テンプレート（.env.example）の更新
- `.env.example` に `MAILER_SENDER` の項目を追加し、利用方法を示す。

## 受け入れ条件

### 送信元アドレスの設定
- [ ] `ApplicationMailer` の `default from` に `ENV.fetch("MAILER_SENDER", "noreply@yomikiri-app.com")` が設定されていること。
- [ ] Deviseの `mailer_sender` に `ENV.fetch("MAILER_SENDER", "noreply@yomikiri-app.com")` が設定されていること。
- [ ] 環境変数 `MAILER_SENDER` が設定されている場合、その設定値がメーラーの送信元アドレスとして使用されること。
- [ ] `.env.example` に `MAILER_SENDER` に関するコメントおよび設定例が追記されていること。

## 成功指標

- レポートメール送信時およびDeviseの認証メール送信時の送信元アドレスが、環境変数 `MAILER_SENDER` の値（未設定の場合は `noreply@yomikiri-app.com`）になること。

## スコープ外

- SendGrid側のDNS認証やドメイン設定（これらはすでに #393 で対処済みまたはインフラ側で対応するため）。

## 参照ドキュメント

- `docs/product-requirements.md` - プロダクト要求定義書
- `docs/development-guidelines.md` - 開発ガイドライン
