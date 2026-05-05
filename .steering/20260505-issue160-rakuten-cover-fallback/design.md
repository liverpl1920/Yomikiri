# 設計書

## 実装アプローチ

### 楽天ブックス書籍検索API

- エンドポイント: `https://app.rakuten.co.jp/services/api/BooksBook/Search/20170404`
- パラメータ: `isbn`, `applicationId`, `format=json`
- レスポンス: `Items[0].Item.largeImageUrl` または `mediumImageUrl`
- APIキー未設定時: `ENV["RAKUTEN_APPLICATION_ID"]` が blank ならスキップ
- タイムアウト: 5秒（既存の fetch_json と同様）

### フォールバック優先順位

```
openBD (cover.openbd.jp) → 楽天ブックス → Google Books thumbnail
```

- openBD: 日本の出版社が直接提供。日本語書籍に強い。APIキー不要。
- 楽天ブックス: 国内書籍の書影カバー率が高い。APIキー必要。
- Google Books: 海外本やその他の予備。thumbnailは直接表示に問題があるケースもあるが、cover_proxy経由で対応済み。

### cover_proxy ドメイン確認

- 楽天の書影URL (`thumbnail.image.rakuten.co.jp`) は直接 `<img>` 表示可能
- `ALLOWED_COVER_HOSTS` には `books.google.com` のみが含まれる
- 楽天URLは `cover_proxy` を通さずに直接保存・表示される

### 変更対象ファイル

| ファイル | 変更内容 |
|---------|---------|
| `app/controllers/books_controller.rb` | `lookup_rakuten_cover_url` 追加、`search_by_isbn`/`search_by_title` のフォールバック変更 |
| `spec/requests/books_search_spec.rb` | 楽天フォールバックのテストケース追加 |

### 実装方針

1. `lookup_rakuten_cover_url(isbn)` メソッドを `lookup_openbd_cover_url` の近くに追加
2. フォールバックロジックを共通化するヘルパー `lookup_cover_url(isbn, google_thumbnail)` を検討
   - ただし、実装の見通しを良くするために各検索メソッド内にインラインで実装してもよい
3. `search_by_isbn` を変更: openBD 検索で書影なしなら楽天 → Google Books で検索
   - Google Books の ISBN 検索: `https://www.googleapis.com/books/v1/volumes?q=isbn:{isbn}`
4. `search_by_title` を変更: openBD 書影なしなら楽天 → Google thumbnail へ

### セキュリティ考慮

- 楽天 API Key は環境変数で管理
- URL は楽天の公式 API から返却されたものを使用するため SSRF リスクなし
- cover_proxy の ALLOWED_COVER_HOSTS は変更不要
