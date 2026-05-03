# 要求内容

## 概要

ISSUE134として、Render本番ビルド時の`assets:precompile`失敗を解消する。具体的には`config/environments/production.rb`でlogger初期化前に発生している危険なログ出力を安全化し、`SENDGRID_API_KEY`未設定でも起動継続できるようにする。

## 背景

`SENDGRID_API_KEY`未設定時の分岐で`Rails.logger.warn`を呼び出すと、初期化タイミングにより`Rails.logger`が`nil`となり`NoMethodError`でアプリ起動とビルドが停止する。Renderのデプロイ工程で`assets:precompile`が失敗し、継続的なデリバリーを阻害している。

## 実装対象の機能

### 1. production環境の安全な警告出力
- logger未初期化でも例外を起こさない警告出力に変更する
- `SENDGRID_API_KEY`未設定時でもActionMailer無効化で起動継続できるようにする

### 2. 再現コマンドによる回帰検証
- Issueで提示された再現コマンドを実行し、失敗しないことを確認する
- 既存Rails規約に従いRSpec/RuboCopで副作用がないことを確認する

## 受け入れ条件

### production環境の安全な警告出力
- [ ] `config/environments/production.rb`の`SENDGRID_API_KEY`未設定分岐で`NoMethodError`が発生しない
- [ ] `SENDGRID_API_KEY`未設定時にメール送信は無効化される
- [ ] アプリ起動時/ビルド時に処理が継続する

### 再現コマンドによる回帰検証
- [ ] `unset RAILS_MASTER_KEY && SECRET_KEY_BASE_DUMMY=1 RAILS_ENV=production bundle exec rails assets:precompile` が成功する
- [ ] `bundle exec rspec` が成功する
- [ ] `bundle exec rubocop` が成功する

## 成功指標

- Renderの`assets:precompile`失敗が再発しない
- `SENDGRID_API_KEY`未設定時でもデプロイ/起動が継続する

## スコープ外

以下はこのフェーズでは実装しない:

- SendGrid設定値そのものの変更
- Renderのインフラ設定変更
- ActionMailer配信仕様の機能追加

## 参照ドキュメント

- `docs/product-requirements.md` - プロダクト要求定義書
- `docs/functional-design.md` - 機能設計書
- `docs/architecture.md` - アーキテクチャ設計書
