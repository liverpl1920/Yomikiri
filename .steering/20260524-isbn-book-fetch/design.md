# 設計書: ISBN書籍情報取得機能 (ISSUE#229)

## 実装方針

### 既存の仕組みの活用
- バックエンドの `BooksController#search` は既にISBN検索をサポート（`/books/search?q=ISBN`）
- openBD APIを使ったISBN検索ロジックは `search_by_isbn` として実装済み
- Stimulus controller `book-form` がフォームの入力自動化を担っている

### 追加実装

#### 1. フォームにISBN入力フィールドを追加（`_form.html.erb`）
- タイトルフィールドの上または下に表示ISBN入力欄を追加
- 「書籍情報を取得」ボタンをフィールドに隣接して配置
- フォーム送信に使用する既存の hidden `isbn` フィールドとは別に表示用入力欄を用意
- ステータスメッセージ表示要素を追加

#### 2. Stimulus コントローラーの更新（`book_form_controller.js`）
- `isbnInput` ターゲットを追加
- `fetchByIsbn()` メソッドを追加
  - ISBN入力値を取得
  - `/books/search?q=ISBN` へリクエスト
  - 結果をフォームに反映（titleフィールドも含む）
  - エラー時はステータスメッセージ表示
- `_fillFormFromSearch` でタイトルフィールドも更新対応（現在は著者・ジャンル・ページ数のみ）
- `_buildFetchResultMessage` をISBN取得向けに調整

### フォームレイアウト
```
[ISBN入力欄（任意）] [書籍情報を取得ボタン]
[ステータスメッセージ]
[タイトル入力欄（必須）]
...
```

### エラーハンドリング
- ISBNが空：何もしない（ボタン無効化または無視）
- ISBNが不正フォーマット：「有効なISBN（13桁または10桁）を入力してください」
- openBDに存在しない：「ISBNに一致する書籍が見つかりませんでした」
- ネットワークエラー：「取得中にエラーが発生しました」

### 状態管理
- タイトル取得のステータス表示と同じ `titleStatus` ターゲットを使う
- または専用の `isbnStatus` ターゲットを追加

## テスト方針

### フロントエンド
- JavaScript単体テストは既存のJS周りのテストがないため省略
- System specでISBN入力→取得→フォーム反映を検証

### バックエンド
- 既存の `books_search_spec.rb` がISBN検索をカバー済み
- 追加変更なし（バックエンドに変更がないため）

### Request spec
- フォームの表示（new画面にISBNフィールドが存在する）を確認
