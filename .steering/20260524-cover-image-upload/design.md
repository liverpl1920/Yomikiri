# 設計書

## 実装アプローチ

### 方針
- Active Storage を再有効化して `has_one_attached :cover_image` を使う
- 既存の `cover_image_url`（API取得URL）との共存: Active Storage 添付を優先し、なければ `cover_image_url` を使用する
- ローカル開発: Disk ストレージ（設定済み）
- 本番（Render）: S3 互換ストレージ（環境変数による設定）

### データフロー

```
[ユーザー] -- ファイルアップロード --> [form multipart/form-data]
    --> BooksController#create/update
    --> book.cover_image.attach(params[:book][:cover_image])
    --> ActiveStorage::Blob / ActiveStorage::Attachment
    --> 表示時: rails_blob_url(book.cover_image)
```

### 表示ロジック

```ruby
# BooksHelper#book_cover_src の拡張
def book_cover_src(book)
  if book.cover_image.attached?
    rails_blob_url(book.cover_image)
  elsif book.cover_image_url.present?
    # 既存の URL ベース表示（後方互換）
    ...
  end
end
```

### バリデーション

| 項目 | 制限 |
|------|------|
| ファイル形式 | JPEG / PNG / WebP |
| ファイルサイズ | 最大 5MB |

```ruby
# Book モデル
validate :cover_image_content_type, if: -> { cover_image.attached? }
validate :cover_image_size, if: -> { cover_image.attached? }
```

## 変更ファイル一覧

| ファイル | 変更内容 |
|---------|---------|
| db/migrate/YYYYMMDDHHMMSS_recreate_active_storage_tables.rb | Active Storage テーブル再作成 |
| config/storage.yml | S3 設定を追加 |
| config/environments/production.rb | 本番ストレージ設定 |
| app/models/book.rb | has_one_attached :cover_image, バリデーション追加 |
| app/helpers/books_helper.rb | book_cover_src をBook引数に変更 |
| app/views/books/_form.html.erb | アップロードフィールド追加 |
| app/views/books/index.html.erb | 書影表示ロジック更新 |
| app/views/books/show.html.erb | 書影表示ロジック更新 |
| app/controllers/books_controller.rb | Strong Parameters 更新 |
| render.yaml | ストレージ環境変数追加 |
| spec/models/book_spec.rb | cover_image バリデーションテスト追加 |

## 注意事項

- `has_one_attached` を追加するとき `include ActiveStorage::Blob` は不要（Rails 7.2 標準）
- `content_type_in` は Rails 7.2 では `content_type` バリデーションで実装する
- ヘルパーの引数変更に伴い、全呼び出し箇所（index.html.erb, show.html.erb）を更新する
