# 設計書

## アーキテクチャ概要

Rails バックエンドにプロキシエンドポイントを設け、Stimulus コントローラーから呼び出す設計。
外部APIへの直接フェッチは行わず、Rails経由にすることでテスト時のスタブが容易になる。

```
ブラウザ (Stimulus)
  └─ GET /books/search?q=QUERY
       └─ BooksController#search
            ├─ ISBN判定: openBD API (https://api.openbd.jp/v1/get?isbn=...)
            └─ タイトル判定: Google Books API (https://www.googleapis.com/books/v1/volumes?q=...)
```

## コンポーネント設計

### 1. BooksController#search（新規アクション）

**責務**:
- クエリ文字列を受け取り、ISBN/タイトルを判定して適切な外部APIを呼び出す
- 結果を統一形式のJSONで返す

**実装の要点**:
- `before_action :authenticate_user!` が適用される（既存）
- `Net::HTTP` + SSL でオープンBD/Google Books を呼び出す
- タイムアウト: open_timeout 5秒, read_timeout 5秒
- エラー時は空配列 `{ books: [] }` を返す（エラーメッセージはフロントで表示）

**レスポンス形式**:
```json
{
  "books": [
    {
      "title": "書籍タイトル",
      "author": "著者名",
      "total_pages": 260,
      "cover_image_url": "https://cover.openbd.jp/9784873115658.jpg"
    }
  ]
}
```

### 2. book_search_controller.js（新規Stimulusコントローラー）

**責務**:
- 検索UIの操作（入力・ボタン・候補リスト表示）
- `/books/search?q=...` への非同期リクエスト
- 結果に応じてフォームフィールドを自動補完

**targets**:
- `query`: 検索入力フィールド
- `status`: ステータスメッセージ表示領域
- `results`: 候補一覧リスト

**外部フォームフィールドへのアクセス**:
- `book_form_controller.js` が管理するフィールドに `id` 経由でアクセス（`book_title`, `book_author`, `book_total_pages`, `book_cover_image_url`）
- total_pages 更新時は `input` イベントを発火して `book-form` の quota 計算を連動させる

### 3. _form.html.erb の変更

**変更内容**:
- フォームの先頭（タイトルフィールドの上）に検索セクションを追加
- `data-controller="book-search"` を付けた `<div>` に検索UIをまとめる

### 4. CSS（books.css への追記）

**追加クラス**:
- `.book-search`: 検索セクション全体のコンテナ
- `.book-search__input-group`: 入力フィールドとボタンの横並びグループ
- `.book-search__input`: テキスト入力フィールド
- `.book-search__button`: 検索ボタン
- `.book-search__status`: ステータスメッセージ
- `.book-search__results`: 候補一覧リスト（`ul`）
- `.book-search__result-item`: 候補アイテム（`li`）

## データフロー

### ISBNで検索する場合
```
1. ユーザーがISBNを入力し「検索」ボタンを押す
2. Stimulus → GET /books/search?q=9784873115658
3. Controller: ISBN判定（\A\d{10,13}\z にマッチ）
4. Controller: openBD API呼び出し
5. Controller: JSON整形して返却（1件）
6. Stimulus: 1件なのでフォームに直接補完
7. UI: 「書籍情報を自動入力しました」表示
```

### 書籍名で検索する場合
```
1. ユーザーが書籍名を入力し「検索」ボタンを押す
2. Stimulus → GET /books/search?q=リーダブルコード
3. Controller: タイトル判定（ISBNパターン不一致）
4. Controller: Google Books API呼び出し（最大5件）
5. Controller: JSON整形して返却（複数件）
6. Stimulus: 候補リストを表示
7. ユーザーが候補をクリック
8. Stimulus: フォームに補完
9. UI: 「書籍情報を自動入力しました」表示
```

## エラーハンドリング戦略

| 状況 | 対処 |
|------|------|
| 外部APIタイムアウト | `{ books: [] }` を返し、フロントで「検索中にエラーが発生しました」 |
| 書籍が見つからない | `{ books: [] }` を返し、フロントで「該当する書籍が見つかりませんでした」 |
| 検索クエリ空 | レンダリングをスキップ（JSレベルで制御） |
| ネットワーク失敗（fetch） | fetchのcatchでエラーメッセージを表示 |

## テスト戦略

### Request spec（`spec/requests/books_search_spec.rb`）
- WebMock で openBD/Google Books APIをスタブ
- ISBN検索でJSON形式の書籍データが返ること
- タイトル検索で複数件返ること
- 存在しないISBNで空配列が返ること
- 未ログイン時に302リダイレクトされること

### System spec（`spec/system/books/book_search_spec.rb`、`js: true`）
- ISBN入力 → 検索 → フォームに値が補完されること
- タイトル入力 → 検索 → 候補一覧表示 → 選択 → フォーム補完されること
