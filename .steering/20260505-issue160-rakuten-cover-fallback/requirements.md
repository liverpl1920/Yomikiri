# 要求内容

## 概要

書影URLの取得ソースを複数組み合わせ、openBD → 楽天ブックス → Google Books の優先順位でフォールバックする仕組みに統一する。

## 背景

現状の実装では `search_by_isbn` は openBD のみ、`search_by_title` は Google Books → openBD の非対称な戦略となっており、楽天ブックスAPIが使われていないため国内書籍で書影なしになるケースが多い。

## 実装対象の機能

### 1. 楽天ブックス書籍検索API連携

- `RAKUTEN_APPLICATION_ID` 環境変数を追加する
- `lookup_rakuten_cover_url(isbn)` ヘルパーメソッドを実装する
  - エンドポイント: `https://app.rakuten.co.jp/services/api/BooksBook/Search/20170404`
  - ISBNで検索し `largeImageUrl` または `mediumImageUrl` を返す
  - API キーが未設定の場合はスキップする（環境差異への耐性）

### 2. search_by_isbn フォールバック変更

- openBD → 楽天ブックス → Google Books の順でフォールバックする
- 書影が見つからなかった場合のみ次のソースへ進む

### 3. search_by_title フォールバック統一

- openBD → 楽天ブックス → Google Books の順に統一する
- 現状の openBD → Google thumbnail の流れを変更する

### 4. cover_proxy ドメイン確認

- 楽天URLは直接 `<img>` 表示可能なため `cover_proxy` 不要であることを確認する

## 受け入れ条件

### フォールバック戦略
- [ ] ISBN検索・タイトル検索ともに同じ優先順位（openBD → 楽天 → Google Books）でフォールバックする
- [ ] 楽天APIキーが未設定の場合は楽天ステップをスキップして次にフォールバックする
- [ ] 各APIの呼び出しに5秒タイムアウトを維持する

### テスト
- [ ] RSpec でフォールバックの各ケース（openBDあり / openBDなし楽天あり / 両方なしGoogleあり / 全部なし）をテストする
- [ ] RSpec / RuboCop が全通過する

## スコープ外

以下はこのフェーズでは実装しません:

- 楽天ブックスAPIの書籍情報（タイトル・著者・ページ数）取得
- 楽天URLの cover_proxy 対応（不要なため）
- キャッシュ機能

## 参照ドキュメント

- `docs/architecture.md` - アーキテクチャ設計書（外部API一覧）
- `app/controllers/books_controller.rb` - 現行実装
- `spec/requests/books_search_spec.rb` - 既存テスト
