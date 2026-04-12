# 設計書: 書影を外部URL文字列保存に戻す（Issue #114）

## 実装アプローチ

### データ設計

```
books テーブル（追加カラム）
  cover_image_url: string, null: true
```

### モデルバリデーション

```ruby
validates :cover_image_url, length: { maximum: 2048 }, allow_blank: true
validate :cover_image_url_must_be_valid_url, if: -> { cover_image_url.present? }

private

def cover_image_url_must_be_valid_url
  uri = URI.parse(cover_image_url)
  unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
    errors.add(:cover_image_url, :invalid_url)
  end
rescue URI::InvalidURIError
  errors.add(:cover_image_url, :invalid_url)
end
```

### ビュー設計

書影表示ロジック（index / show 共通）：
```erb
<% if book.cover_image_url.present? %>
  <img src="<%= book.cover_image_url %>" alt="<%= book.title %>の書影"
       class="book-card__cover-image" loading="lazy">
<% else %>
  <span class="book-card__cover-placeholder" aria-hidden="true">📖</span>
<% end %>
```

### Active Storage 撤去方針

1. `db/migrate/20260412051624_create_active_storage_tables.active_storage.rb` を削除
2. Active Storageテーブルをdropするmigrationを新規作成
   - スキーマが既にactive_storageテーブルを持っているため

### i18n

`config/locales/ja.yml` の `activerecord.attributes.book` に `cover_image_url: 書影URL` を追加。  
エラー: `cover_image_url.invalid_url: URLの形式が正しくありません`。

### テスト設計

**model spec**:
- `cover_image_url` が nil → valid
- `cover_image_url` が有効URL → valid
- `cover_image_url` が不正文字列 → invalid（エラーメッセージ確認）

**request spec**:
- POST /books with `cover_image_url` → 保存される
- GET /books → `cover_image_url` を持つ本が表示される
