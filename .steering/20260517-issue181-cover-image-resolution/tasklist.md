# タスクリスト - 書影画像の解像度改善 (Issue #181)

## フェーズ1: Controller 実装

- [x] `best_google_image_url` プライベートメソッドを追加（imageLinksからサイズ優先でURL取得）
- [x] `search_by_title` の Google Books 画像取得を `best_google_image_url` に変更
- [x] `lookup_google_books_cover_url` を `best_google_image_url` 使用に変更

## フェーズ2: CSS 改善

- [x] `book-card__cover img` に高密度ディスプレイ向けCSS追加
- [x] `book-show__cover` の img に高密度ディスプレイ向けCSS追加

## フェーズ3: テスト更新

- [x] `GET /books/search` (タイトル検索) のテストを追加（imageLinks に large サイズある場合）
- [x] `GET /books/search` (ISBN検索) のテストを追加（タイトル検索テストに統合）
- [ ] 既存テストが通ることを確認

## フェーズ4: 検証

- [x] RSpec 全テスト実行・確認（401例、0失敗）
- [x] RuboCop 実行・確認（オフェンスなし）

---

## 振り返り（実装完了後に記載）

### 実装完了日: 2026-05-17

### 計画と実績の差分
- 計画通り `best_google_image_url` メソッドを追加し、`extraLarge > large > medium > small > thumbnail > smallThumbnail` の優先順でURL取得するように実装した
- openBD API はサイズバリエーションを提供しないため、既存の `summary.cover` をそのまま使用（変更なし）
- Rakuten API はすでに `largeImageUrl` を優先しており変更不要だった
- CSS は `image-rendering: auto` を追加し、`book-show__cover-image` の img スタイルルールを新規追加

### 学んだこと
- Google Books API の `imageLinks` には `extraLarge`, `large`, `medium`, `small`, `thumbnail`, `smallThumbnail` の6段階が存在する
- テストの HTTP モックは `Net::HTTP` レベルよりもコントローラーメソッドレベルでスタブする方が安定する（`Net::HTTP.start` のブロック内は接続処理があるため）
- `instance_double` を使った `case/when` のモックは複雑になりやすい

### 次回への改善提案
- openBD API が高解像度オプションを提供する場合は `lookup_openbd_cover_url` も改善できる
- Google Books の `zoom` パラメータを使って動的にサイズ指定できるか検討の余地がある
