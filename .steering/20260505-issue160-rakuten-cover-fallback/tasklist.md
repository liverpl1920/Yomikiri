# タスクリスト

## 🚨 タスク完全完了の原則

**このファイルの全タスクが完了するまで作業を継続すること**

---

## フェーズ1: 楽天ブックスAPI連携実装

- [x] `lookup_rakuten_cover_url(isbn)` メソッドを `BooksController` に追加する
  - `RAKUTEN_APPLICATION_ID` が blank の場合は `""` を返す
  - `https://app.rakuten.co.jp/services/api/BooksBook/Search/20170404` エンドポイントへISBN検索
  - `largeImageUrl` → `mediumImageUrl` の優先順でURLを返す
  - 取得失敗・空配列の場合は `""` を返す
  - タイムアウトは5秒（fetch_json を使用）

## フェーズ2: search_by_isbn のフォールバック変更

- [x] `search_by_isbn` を openBD → 楽天 → Google Books の順に変更する
  - openBD で書影あり → そのまま返す
  - openBD で書影なし → 楽天 `lookup_rakuten_cover_url` で取得を試みる
  - 楽天でも書影なし → Google Books ISBN 検索 (`q=isbn:{isbn}`) でサムネイルを取得
  - すべて失敗 → `""` を返す

## フェーズ3: search_by_title のフォールバック統一

- [x] `search_by_title` を openBD → 楽天 → Google Books の順に統一する
  - 現状: openBD → Google thumbnail
  - 変更後: openBD → 楽天 → Google thumbnail

## フェーズ4: テスト追加

- [x] ISBN検索で openBD あり の場合のテスト（既存確認）
- [x] ISBN検索で openBD なし・楽天あり の場合のテスト追加
- [x] ISBN検索で openBD・楽天なし・Google Books あり の場合のテスト追加
- [x] ISBN検索で全部なし の場合のテスト追加
- [x] タイトル検索で openBD なし・楽天あり の場合のテスト追加
- [x] タイトル検索で openBD・楽天なし・Google thumbnail の場合のテスト（既存確認）
- [x] 楽天 RAKUTEN_APPLICATION_ID 未設定時スキップのテスト追加

## フェーズ5: 検証

- [x] RuboCop を実行してエラーがないことを確認
- [x] RSpec を実行して全テストが通過することを確認

---

## 振り返り

**実装完了日:** 2026-05-05

### 計画と実績の差分

- `resolve_cover_url` という共通ヘルパーメソッドを追加した（設計書の「インラインでもよい」を超えてリファクタリングした）。これにより `search_by_isbn` と `search_by_title` 両方で同一ロジックを使い回せた。
- `lookup_google_books_cover_url(isbn)` も新設し、ISBN から Google Books のサムネイルを直接取得するメソッドとした（`search_by_isbn` からの Google フォールバックに必要）。
- テストの WebMock スタブの正規表現でクエリパラメータ順序のはまりあり。`?q=isbn` で固定すると実際のURL `?maxResults=1&q=isbn:...` にマッチしないため、`.*q=isbn` に変更した。

### 学んだこと

- Ruby の `URI.encode_www_form` はパラメータをアルファベット順で出力しない（渡した順番）ため、WebMock スタブでは `\?q=` の固定マッチより `.*q=` の部分マッチが安全。
- `ENV["KEY"].to_s` と `.blank?` の組み合わせで、未設定（nil → ""）・空文字両方に対応できる。

### 次回への改善提案

- 楽天APIの実際の APIキーを Render の環境変数に追加することで、本番環境での書影カバー率が向上する（Issue #160 の本来の目的）。
- キャッシュ（Rails.cache）を導入すると、同一ISBN の重複 API コールを削減できる。
