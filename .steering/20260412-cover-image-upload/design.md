# 設計: 書影アップロード機能 (Issue #26)

## 実装アプローチ

### モデル層
`Book` モデルに Active Storage アタッチメントとバリデーションを追加する。

```ruby
# app/models/book.rb
has_one_attached :cover_image

validates :cover_image, content_type: [ :png, :jpg, :jpeg, :gif, :webp ],
                         size: { less_than: 5.megabytes }
```

### コントローラー層
`book_params` に `:cover_image` を追加する。

```ruby
def book_params
  params.require(:book).permit(:title, :author, :total_pages, :target_pages,
                                :current_page, :deadline, :status, :cover_image)
end
```

### ビュー層

**フォーム (_form.html.erb)**:
- `f.file_field :cover_image` を追加する
- フォームに `multipart: true` オプションが必要（`form_with` はデフォルトで自動付与）

**一覧画面 (index.html.erb)**:
- `book.cover_image.attached?` で分岐
- 書影あり: `image_tag book.cover_image` を表示
- 書影なし: 既存のプレースホルダー絵文字 📖

**詳細画面 (show.html.erb)**:
- 同様の分岐ロジック

### プレースホルダー
Active Storage による画像がない場合は既存の 📖 絵文字をそのまま使用する（シンプルさを優先）。

### バリデーションエラー表示
既存のフォームエラー表示 (`book.errors.full_messages`) に統合されるため、特別な対応は不要。

### i18n
バリデーションエラーメッセージ用の日本語ロケールを `config/locales/ja.yml` に追加する。
