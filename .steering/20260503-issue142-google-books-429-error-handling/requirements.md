# 要求内容

## 概要

書影検索（タイトル検索）でGoogle Books APIが429（レートリミット）や5xxを返した場合に、現在は無反応になるバグを修正する。エラー時に明確なメッセージをユーザーへ返す。

## 背景

- `BooksController#search_by_title` は内部で `fetch_json` を呼び出しているが、`fetch_json` は `Net::HTTPSuccess` 以外をすべて `nil` に変換してしまう
- 429/5xx のような一時的エラーは `nil` として扱われ、空配列が返ることで UI 上は「無反応」になる
- ユーザーは検索が機能していないと感じ、UX が大きく損なわれる

## 実装対象の機能

### 1. Google Books API エラーハンドリング改善

- `fetch_json` または呼び出し元で 429/5xx を判別できるようにする
- 429/5xx の場合はフロントエンドへ `error` フィールドを含むレスポンスを返す
- `search` アクションの JSON レスポンスに `error` キーが含まれるようにする

### 2. request spec の追加

- Google Books API が 429 を返した場合のシナリオを request spec で検証する
- レスポンスに `error` キーが含まれ、ユーザーに原因が分かる文言であることを検証する

## 受け入れ条件

### エラーハンドリング
- [ ] タイトル検索時に Google Books API が 429 を返した場合、`books: []` かつ `error: <メッセージ>` を含む JSON を返す
- [ ] タイトル検索時に Google Books API が 5xx を返した場合、同様のエラー JSON を返す
- [ ] 正常ケース（200）は従来どおり `books: [...]` を返す

### テスト
- [ ] request spec で 429 ケースを再現し、`error` キーを含むことを検証する
- [ ] 既存の request spec が引き続き全通過する

### フロントエンド（Stimulusコントローラー）
- [ ] `error` キーが返ってきた場合に、エラーメッセージを画面に表示する

## スコープ外

- タイトル検索失敗時のリトライ機能（フォールバック戦略）
- ISBN 入力 UI の変更（これは Issue #143 で対応予定）
- openBD API のエラーハンドリング改善（既存の動作を維持）

## 参照ドキュメント

- `docs/architecture.md` - アーキテクチャ設計書
- `docs/development-guidelines.md` - 開発ガイドライン
