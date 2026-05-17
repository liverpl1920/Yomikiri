# 設計書 - 書影画像の解像度改善 (Issue #181)

## 実装アプローチ

### BooksController の変更

#### `search_by_title` メソッド
- Google Books の `imageLinks` から `extraLarge` > `large` > `medium` > `small` > `thumbnail` の優先順で取得
- 既存の `google_thumbnail` 変数を `google_cover_url` にリネームし、サイズ優先ロジックを適用

#### `lookup_google_books_cover_url` メソッド
- ISBN検索時に使用するGoogle Books カバー取得も同様に大サイズ優先に変更

#### `best_google_image_url` ヘルパーメソッド（新規追加）
- `imageLinks` ハッシュから最高解像度URLを返す private メソッド
- 優先順位: `extraLarge` > `large` > `medium` > `small` > `thumbnail` > `smallThumbnail`

### CSS の変更 (`books.css`)
- `book-card__cover img` に `image-rendering: high-quality` を追加（標準ではないため削除）
- 高密度ディスプレイ向けに `@media` クエリを追加（`-webkit-min-device-pixel-ratio: 2`）
- `object-fit: contain` を `cover` から `contain` に変更（書影の縦横比を保持するため）

### テストの変更
- `GET /books/search` のテストを追加（ISBNおよびタイトル検索）
- Google Books imageLinks に複数サイズある場合の期待値テスト

## 変更の影響範囲

| コンポーネント | 変更内容 | リスク |
|------------|---------|--------|
| BooksController | imageLinks サイズ取得ロジック変更 | 低（フォールバックあり） |
| books.css | 画像表示CSS改善 | 低（視覚的変更のみ） |
| spec/requests/books_spec.rb | テスト更新 | 低 |
