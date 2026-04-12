# 設計書 - 外部ストレージ（Active Storage）の設定

## アーキテクチャ方針

### ストレージ構成

| 環境 | サービス | 理由 |
|------|----------|------|
| development | :local | ローカルファイルシステムを利用、シンプルで高速 |
| test | :test | インメモリテスト用、フィクスチャ不要 |
| production | :amazon (S3) | スケーラブル、耐障害性、Render との相性が良い |

### 認証情報管理方針

- Rails credentials ファイルではなく、**環境変数**で AWS 認証情報を管理する
- 理由: Render の環境変数機能との統合が容易であるため
- `storage.yml` で `ENV[]` を使って環境変数を参照する

### gem 選択

- `aws-sdk-s3`: Active Storage の Amazon S3 バックエンド用 AWS SDK
- バージョン指定: `>= 1.14` (Active Storage のガイドラインに準拠)

## 実装方針

### 1. Gemfile への追加

```ruby
gem "aws-sdk-s3", ">= 1.14", require: false
```

`require: false` を指定し、必要な時のみロードされるようにする。

### 2. Active Storage インストール

```bash
bin/rails active_storage:install
bin/rails db:migrate
```

生成されるマイグレーション:
- `active_storage_blobs` - アップロードされたファイルのメタデータ
- `active_storage_attachments` - レコードとblobの関連付け
- `active_storage_variant_records` - 画像バリアント管理

### 3. storage.yml の設定

```yaml
amazon:
  service: S3
  access_key_id: <%= ENV["AWS_ACCESS_KEY_ID"] %>
  secret_access_key: <%= ENV["AWS_SECRET_ACCESS_KEY"] %>
  region: <%= ENV["AWS_REGION"] %>
  bucket: <%= ENV["AWS_BUCKET"] %>
```

### 4. production.rb の修正

```ruby
config.active_storage.service = :amazon
```

### 5. render.yaml の修正

S3 関連の環境変数を `sync: false` で追加（値はRenderダッシュボードで設定）:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`
- `AWS_BUCKET`

## セキュリティ考慮

- AWS 認証情報は絶対にソースコードにハードコードしない
- `.gitignore` に `.env` が含まれていることを確認する（既存設定）
- `render.yaml` では `sync: false` を使用し、実際の値は Render ダッシュボードで管理する
