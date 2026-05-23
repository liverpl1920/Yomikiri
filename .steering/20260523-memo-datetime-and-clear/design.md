# design.md

## 実装アプローチ

### データ層の変更
- `books` テーブルに `memo_updated_at` (datetime, nullable) カラムを追加
- `Book` モデルへの明示的な変更は不要（Active Record が自動管理）

### コントローラー変更 (`BooksController#update_memo`)
- `@book.update(memo_params)` 成功時に `memo_updated_at: Time.current` を同時に更新
- `flash[:memo_saved] = true` をセットしてリダイレクト
  - これによりビュー側でリダイレクト後の「保存直後」を判定できる

### ビュー変更 (`books/show.html.erb`)
- テキストエリアの value:
  - `flash[:memo_saved]` が true の場合 → value: '' (空)
  - それ以外 → value: @book.memo (既存動作)
- 保存済みメモのプレビューエリアに日時を追加:
  - `@book.memo_updated_at` が存在する場合 → `l(@book.memo_updated_at, format: :default)` を表示

### テスト方針
- `spec/requests/books_spec.rb` に以下を追加:
  - `memo_updated_at` がメモ保存時に更新される
  - リダイレクト後のレスポンスに入力欄が空の状態（value属性なし or value=""）で表示される
  - `memo_updated_at` が表示される

### 移行方針
- `memo_updated_at` は nullable なので既存レコードへの影響なし
- 初回メモ保存時から日時が記録される
