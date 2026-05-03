# 設計書

## 方針

既存の `/books/search` API と `book_form_controller.js` を拡張し、サーバー側で書影URLの信頼性を担保する。UI構造は維持し、挙動のみ改善する。

## 変更設計

### 1. BooksController
- `search_by_title` で `industryIdentifiers` から ISBN-13 を抽出。
- 抽出した ISBN を openBD で照会し、取得できた場合のみ `https://cover.openbd.jp/<isbn13>.jpg` を `cover_image_url` として返す。
- openBD取得できない候補は `cover_image_url: ""` を返す。

### 2. book_form_controller.js
- 自動取得処理を Promise 化し、実行中状態を管理。
- 新規 `submitWithAutoFetch` を追加。
  - タイトルが入力済みかつ当該タイトルの自動取得未実行なら送信を一時停止。
  - 自動取得完了後に再送信。
- 429時など APIエラー時は既存フォールバック表示を維持。

### 3. フォーム
- `form_with` に `submit->book-form#submitWithAutoFetch` を追加し、送信前ガードを有効化。

### 4. テスト
- request spec: タイトル検索時の書影URL期待値を openBD URL へ変更。
- system spec:
  - タイトル検索成功時の書影URL期待値を openBD URL へ更新。
  - 429時のISBNフォールバック取得が機能することを追加。
  - 「入力後すぐ送信」で書影URLが保存されることを追加。

## リスクと対策

- openBD呼び出し回数増加: 候補最大5件のため許容。タイムアウト時は空URLで安全にフォールバック。
- submit再送信ループ: Stimulus側に再送信フラグを持たせて一度だけ再送する。
