# 設計書 - Issue #143: タイトル入力から自動でISBN・書影を取得

## 実装アプローチ

### 1. 自動取得フロー

```
ユーザーがタイトル入力 → フォーカスを外す（blur） → `/books/search?q=<title>` を呼び出し
  ↓
  書影あり → 書籍情報（著者・ページ数・書影URL）を自動入力 → 成功メッセージ表示
  ↓
  書影なし・結果なし → 案内メッセージ + ISBNフォールバック入力欄を表示
    ↓
    ユーザーがISBN入力 → 「取得する」ボタン → `/books/search?q=<isbn>` を呼び出し
      ↓
      書影あり → 書影URLを自動入力 → 成功メッセージ
      書影なし → 失敗メッセージ（ISBN未入力でも登録は可能）
```

### 2. UIコンポーネント

#### タイトルフィールド周辺
- タイトル入力欄に `data-action="blur->book-form#autoFetchByTitle"` を追加
- ステータス表示用 `<p>` タグを追加（`data-book-form-target="titleStatus"`）

#### ISBNフォールバックセクション（初期非表示）
- 取得失敗時のみ表示
- ISBN入力欄 (`data-book-form-target="isbn"`)
- 「取得する」ボタン (`data-action="click->book-form#fetchByIsbn"`)
- ISBNステータス表示 (`data-book-form-target="isbnStatus"`)

### 3. book_form_controller.js 変更内容

#### 追加するターゲット
- `title`: タイトル入力欄
- `titleStatus`: タイトル取得ステータス表示
- `isbnSection`: ISBNフォールバックセクション全体
- `isbn`: ISBN入力欄
- `isbnStatus`: ISBN取得ステータス表示

#### 追加するメソッド
- `autoFetchByTitle()`: タイトルからISBN/書影を自動取得
- `fetchByIsbn()`: ISBNから書影を取得
- `_showIsbnFallback(message)`: ISBNフォールバックセクションを表示
- `_hideIsbnSection()`: ISBNフォールバックセクションを非表示
- `_fillFormFromSearch(book)`: 検索結果でフォームを埋める

### 4. 既存実装との関係

- `/books/search` エンドポイントは既存のまま使用（変更不要）
- 既存の `book-search` セクション（上部の検索ボックス）は残す
- 新機能はタイトルフィールドへのブラーイベントで動作

### 5. スタイル変更

- `.book-form__isbn-section` - ISBNフォールバックセクション
- `.book-form__isbn-section--hidden` - 非表示時
- `.book-form__isbn-input-group` - ISBN入力とボタンの横並び
- `.book-form__title-status` - ステータステキスト
- `.book-form__isbn-status` - ISBNステータステキスト
