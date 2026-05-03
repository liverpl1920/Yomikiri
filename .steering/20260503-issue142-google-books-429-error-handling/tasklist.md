# タスクリスト

## 🚨 タスク完全完了の原則

**このファイルの全タスクが完了するまで作業を継続すること**

### 必須ルール
- **全てのタスクを`[x]`にすること**
- 「時間の都合により別タスクとして実施予定」は禁止
- 未完了タスク（`[ ]`）を残したまま作業を終了しない

---

## フェーズ1: バックエンド実装

- [x] BooksController に GoogleBooksApiError カスタム例外を追加する
- [x] `fetch_title_json` メソッドを新規追加（429/5xx を例外として raise する）
- [x] `search_by_title` を `fetch_title_json` を使うよう変更する
- [x] `search` アクションの rescue に `GoogleBooksApiError` を追加し error キーを返す

## フェーズ2: フロントエンド実装

- [x] `book_search_controller.js` の既存エラー表示ロジックを確認する
- [x] `error` キーが返ってきた場合にエラーメッセージを表示するよう修正する

## フェーズ3: テスト実装

- [x] `spec/requests/books_search_spec.rb` に 429 ケースの request spec を追加する
  - [x] Google Books API が 429 を返した場合に `error` キーが含まれることを検証
  - [x] Google Books API が 503 を返した場合に `error` キーが含まれることを検証
- [x] `bundle exec rspec spec/requests/books_search_spec.rb` が全通過することを確認する

## フェーズ4: 品質チェック

- [x] `bundle exec rspec` が全通過することを確認する
- [x] `bundle exec rubocop` にエラーがないことを確認する

---

## 実装後の振り返り

### 実装完了日
2026-05-03

### 計画と実績の差分

**計画と異なった点**:
- validator のレビューにより、`fetch_title_json` 末尾の `rescue StandardError` が `nil` を返す設計（意図が不明確）を `raise GoogleBooksApiError` に変更した
- `GoogleBooksApiError` 定数の定義位置をアクションメソッドの間から `before_action` の上に移動した
- タイムアウト spec（Google Books API 経路）を validator 指摘により追加した（設計書の「スコープ外」には含まれていなかったが、`fetch_title_json` に対応 rescue があるため追加が適切）

### 学んだこと

- 既存の `fetch_json`（silently nil を返す）と、新規の `fetch_title_json`（エラー時 raise）の責務を明確に分けることで、openBD（ISBN 検索）の挙動を壊さずに Google Books のエラーハンドリングを強化できた
- コントローラー内のクラス定数は `before_action` より前に定義するのが慣習上わかりやすい
- エラーハンドリングの rescue チェーンは `StandardError` を最後に置き、汎用エラーもユーザー向けメッセージとして raise することで「無反応」状態を防げる

### 次回への改善提案

- タイトル検索失敗時のリトライ機能（例: 別クエリ戦略や短時間後リトライ）は Issue #143 で別途対応を検討する
- `fetch_json` と `fetch_title_json` の共通部分（`Net::HTTP.start` ブロック）を抽出してメソッド共有化を検討するが、現状の重複は1か所のみで軽微なため次の機会に
