# タスクリスト - 外部ストレージ（Active Storage）の設定

## フェーズ1: 依存関係の追加

- [x] GemfileにAWSS3 SDKを追加する（`aws-sdk-s3 >= 1.14, require: false`）
- [x] bundle install を実行する

## フェーズ2: Active Storage インストール

- [x] `bin/rails active_storage:install` でマイグレーションを生成する
- [x] `bin/rails db:migrate` でマイグレーションを適用する
- [x] schema.rb に active_storage の3テーブルが追加されていることを確認する

## フェーズ3: ストレージ設定

- [x] `config/storage.yml` に Amazon S3 の設定を追加する（環境変数参照）
- [x] `config/environments/production.rb` のストレージサービスを `:amazon` に変更する

## フェーズ4: Render 環境変数設定

- [x] `render.yaml` に AWS 関連の環境変数（4つ）を追加する

## フェーズ5: 検証

- [x] `bundle exec rspec` を実行し全テストがパスすることを確認する
- [x] `bundle exec rubocop` を実行しエラーがないことを確認する

---

## 実装後の振り返り

### 実装完了日
2026-04-12

### 計画と実績の差分
- 計画通り全タスクを完了した
- Active Storage の3テーブル（blobs, attachments, variant_records）が正常に作成された
- RSpec 209件すべてパス、RuboCop エラーなし

### 学んだこと
- `aws-sdk-s3 >= 1.14, require: false` が Active Storage の公式推奨設定
- `render.yaml` で `sync: false` を使えば、実際のシークレット値はRenderダッシュボードで別途設定できる（コードにハードコードしない安全な手法）
- Active Storage の設定は development/test 環境は既にデフォルトで `:local` になっていたため、production.rb の変更のみで環境分離が実現できた

### 次回への改善提案
- Issue #26（書影アップロード機能）の実装時は、Book モデルに `has_one_attached :cover_image` を追加し、フォームに `file_field` を追加する
- 画像バリアント（サムネイル生成）には `image_processing` gem（libvips または ImageMagick バックエンド）が必要になる場合がある
- AWS S3 バケットの CORS 設定もデプロイ前に確認が必要

### 実装しなかったタスク
なし（全タスク完了）
