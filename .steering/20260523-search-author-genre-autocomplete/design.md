# 実装設計: 検索著者名・ジャンルオートコンプリート

## 実装方針

### 1. 新規 APIエンドポイント
`BooksController` に `suggestions` アクションを追加する。

- **ルート**: `GET /books/suggestions?field=author&q=テクスト`
- **レスポンス**: `{ suggestions: ["Dustin Boswell", "Yamada Taro"] }`
- `field` パラメータは `author` または `genre` のみ許可（それ以外は400返却）
- `q` パラメータは入力テキスト（空文字列の場合は全件返却）
- `current_user.books` のデータのみ使用（別ユーザーのデータは参照不可）
- 結果数は最大5件まで制限

### 2. 新規 Stimulusコントローラー
`search_filter_autocomplete_controller.js` を新規作成する。

- `title_autocomplete_controller.js` のパターンを参考にしたシンプルな実装
- 入力テキストをそのまま維持（候補選択後も編集可能）
- `/books/suggestions` エンドポイントにフェッチ
- デバウンス300ms、最低1文字以上で起動
- キーボードナビゲーション（ArrowUp/Down, Enter, Escape）対応

### 3. View変更
`app/views/books/index.html.erb` の著者名・ジャンルフィールドに Stimulusコントローラーを追加する。

### 4. CSS追加
`app/assets/stylesheets/books.css` にオートコンプリートドロップダウン用のスタイルを追加する。

## 影響範囲
- `app/controllers/books_controller.rb` (追加)
- `config/routes.rb` (追加)
- `app/javascript/controllers/search_filter_autocomplete_controller.js` (新規)
- `app/views/books/index.html.erb` (変更)
- `app/assets/stylesheets/books.css` (追加)
- `spec/requests/books_spec.rb` (テスト追加)
