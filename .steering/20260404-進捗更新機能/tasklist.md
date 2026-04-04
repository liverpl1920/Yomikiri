# タスクリスト: 進捗更新機能 (Issue #19)

## フェーズ1: ルーティングとコントローラー

- [x] ルートに `patch :update_progress` を追加 (`config/routes.rb`)
- [x] `BooksController` の `before_action :set_book` に `update_progress` を追加
- [x] `BooksController#update_progress` アクションを実装

## フェーズ2: ビュー

- [x] `app/views/books/show.html.erb` に進捗更新フォームを追加
  - 「今日読んだページ数」入力フォーム（±ボタン付き）
  - 折りたたみ式「現在ページを直接入力」フォーム

## フェーズ3: フロントエンド (Stimulus)

- [x] `app/javascript/controllers/progress_update_controller.js` を新規作成
  - ±ボタンでの増減機能
  - 0未満・target_pages 超過の防止
  - 折りたたみ開閉制御

## フェーズ4: スタイル

- [x] `app/assets/stylesheets/books.css` に進捗更新フォームのスタイルを追加

## フェーズ5: テスト

- [x] `spec/requests/books_spec.rb` に `PATCH /books/:id/update_progress` のテストを追加
  - 認証済みユーザーが有効な pages_read で更新できる
  - 認証済みユーザーが直接ページ番号で更新できる
  - pages_read が target_pages を超える場合はバリデーションエラー
  - 未認証ユーザーはリダイレクト
  - 他ユーザーの書籍は 404

## 実装後の振り返り

- **実装完了日**: 2026年4月4日
- **ブランチ**: `feature/#19-update-progress`

### 計画と実績の差分

- 計画通り実装完了。全タスクが `[x]` になった。
- テスト: 131 examples, 0 failures（全体スイート）
- RuboCop: 43 files, no offenses

### 注意した点

- `BooksController#calculate_new_page` をプライベートメソッドに切り出したことで、
  RuboCopの `Layout/EndAlignment` を回避しつつ可読性も向上した。
- `render :show` 時にも `@book` が正しくセットされているため、バリデーションエラーを
  フォームに表示できる。
- 読了済み（`completed?`）の書籍は進捗更新フォームを非表示にするよう `unless @book.completed?` で制御した。

### 学んだこと

- Rails 7.2 では `raise_on_missing_callback_actions` が有効なため、`before_action :set_book, only:` に
  実際に定義したアクション名のみを列挙すること（メモリに記録済み）。

### 次回への改善提案

- 将来の Issue (#18 ノルマ計算) の実装後は、進捗更新後にノルマ再計算が自動で行われることを
  統合テストで確認するとよい。
- `direct_page` と `pages_read` を同時に送信した場合の挙動（`direct_page` 優先）をドキュメントに明記しておくと良い。

