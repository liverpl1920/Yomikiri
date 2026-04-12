# 要求定義書 - 外部ストレージ（Active Storage）の設定

## Issue #25

## 背景・目的

書影アップロード機能（Issue #26）に必要な Active Storage と本番環境クラウドストレージの事前設定を行う。
現時点ではActive Storageのマイグレーションが未実行のため、ファイルアップロード機能を実装する前提となるインフラ整備が必要。

## 要求内容

### 機能要求

1. **Active Storage の導入**
   - `rails active_storage:install` を実行し、必要なマイグレーションを生成・適用する
   - `active_storage_blobs`、`active_storage_attachments`、`active_storage_variant_records` テーブルを作成

2. **本番環境用クラウドストレージの設定**
   - Amazon S3 を本番環境のストレージサービスとして設定する
   - `aws-sdk-s3` gem を Gemfile に追加する
   - `config/storage.yml` に S3 の設定を追加する

3. **環境ごとのストレージサービス設定**
   - 開発環境（development）: `:local`（既存設定を維持）
   - テスト環境（test）: `:test`（既存設定を維持）
   - 本番環境（production）: `:amazon`（S3）に変更する

4. **環境変数の設定**
   - S3 の認証情報を環境変数で管理する（credentials ファイルではなく ENV を使用）
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_REGION`
   - `AWS_BUCKET`
   - `render.yaml` に Render の環境変数定義を追加する

## 非機能要求

- セキュリティ: AWS の認証情報をソースコードにハードコードしない
- 互換性: 既存の開発・テスト環境に影響を与えない

## 完了条件

- [ ] Active Storage のマイグレーションが完了し、schema.rb に3テーブルが追加される
- [ ] 開発環境でファイルアップロードが可能な状態になる
- [ ] 本番環境（Render）で S3 へのファイルアップロードが可能な設定になる
- [ ] AWS 認証情報が環境変数で管理されている
- [ ] RSpec と RuboCop がエラーなく通過する
