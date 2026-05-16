# Issue #178 Design

## 実装方針

### 1. データモデル

- `ReadingLog` モデルを新規追加
	- `belongs_to :book`
	- `pages_read` は 1 以上の整数
	- `read_at` は必須
- `Book` に `has_many :reading_logs, dependent: :destroy` を追加

### 2. ログ記録タイミング

- `BooksController#update_progress` で `current_page` 更新成功時に読書ログを作成
- `pages_read` 入力時は入力値をそのまま記録
- `direct_page` 入力時は増分（`new_page - previous_page`）を記録
- 増分が 0 以下の場合はログを作成しない
- 更新とログ記録は同一トランザクション内で扱う

### 3. 表示

- `MypagesController` で、ログインユーザーの読書ログを
	- `read_at DESC, created_at DESC` で取得
	- `read_at` 単位でグルーピング
- マイページに「日別読書ログ」セクションを追加し、
	- 日付
	- 本タイトル
	- 読んだページ数
	を表示

### 4. テスト

- Request spec:
	- `update_progress` でログ作成されること
	- `direct_page` の増分記録と非増分時未記録を確認
- System spec:
	- マイページに日別読書ログが表示されること
- Model spec:
	- `ReadingLog` バリデーション

## 影響範囲

- `app/controllers/books_controller.rb`
- `app/controllers/mypages_controller.rb`
- `app/views/mypages/show.html.erb`
- `app/assets/stylesheets/mypages.css`
- `app/models/book.rb`
- `app/models/reading_log.rb`
- `db/migrate/*create_reading_logs.rb`
- `spec/*`（request/system/model/factory）
