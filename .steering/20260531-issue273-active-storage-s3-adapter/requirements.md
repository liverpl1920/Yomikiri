# 要求内容

## 概要

Render 本番デプロイ時に Active Storage が `Missing service adapter for "S3"` で起動失敗する問題を解消する。Backblaze B2（S3互換）を利用する現行構成で、S3アダプタ解決に必要な依存関係を明示し、起動不能を防ぐ。

## 背景

- production は `config.active_storage.service = :backblaze` を利用しており、`config/storage.yml` では `service: S3` を参照している。
- S3 サービスのアダプタ解決には `aws-sdk-s3` 系 Gem が必要だが、依存が不足すると起動時に `Missing service adapter for "S3"` で失敗する。
- 既に B2 環境変数バリデーションは導入済みであり、今回は「S3アダプタそのものが解決できる状態」を担保する。

## 実装対象の機能

### 1. S3アダプタ依存の明示
- Gemfile に `aws-sdk-s3` を明示し、production 起動時に Active Storage が `service: S3` を正しく解決できるようにする。
- 依存解決結果を `Gemfile.lock` に反映する。

### 2. 回帰防止テストの維持
- 既存の Active Storage 設定テスト群（storage 設定、production 設定、B2 validator）を通し、今回の変更で想定外の退行がないことを確認する。

## 受け入れ条件

### S3アダプタ依存の明示
- [ ] `Gemfile` に `aws-sdk-s3` が存在する。
- [ ] `Gemfile.lock` に `aws-sdk-s3` と必要な依存が反映されている。

### 起動失敗防止の検証
- [ ] `bundle exec rspec spec/config/storage_config_spec.rb spec/config/production_active_storage_config_spec.rb spec/services/active_storage_s3_config_validator_spec.rb` が成功する。
- [ ] `bundle exec rubocop` が成功する。

## 成功指標

- デプロイ時に `Missing service adapter for "S3"` が再発しない。
- SENDGRID 未設定警告が出る場合でも、ワーカー起動失敗要因が Active Storage 側で発生しない状態を維持できる。

## スコープ外

以下はこのフェーズでは実装しない:

- Backblaze B2 バケット作成・IAM/キー発行などのインフラ作業
- 既存アップロード済みファイルの移行処理
- メール配信（SENDGRID）設定の改善

## 参照ドキュメント

- `docs/product-requirements.md` - プロダクト要求定義書
- `docs/functional-design.md` - 機能設計書
- `docs/architecture.md` - アーキテクチャ設計書
- `docs/development-guidelines.md` - 開発ガイドライン
