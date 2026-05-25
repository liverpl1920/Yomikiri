# 設計書

## 実装アプローチ

### ISSUE#244: メモ編集機能

#### ルーティング
- `resources :book_memos` に `:edit, :update` を追加
- `PATCH /books/:book_id/book_memos/:id` → `book_memos#update`
- `GET /books/:book_id/book_memos/:id/edit` → `book_memos#edit`

#### コントローラー
- `BookMemosController` に `edit`, `update` アクションを追加
- `before_action :set_book_memo` に `:edit, :update` を追加

#### ビュー
- `app/views/book_memos/edit.html.erb` を新規作成（編集フォーム）
- `app/views/books/show.html.erb` のメモタイムライン部分を更新：
  - 編集ボタンの追加
  - `created_at` を常時表示
  - `updated_at != created_at` の場合のみ編集時刻を表示

#### 編集時刻の判定ロジック
```ruby
# edited? メソッドをモデルに追加（1秒以上の差がある場合に編集済みとみなす）
def edited?
  (updated_at - created_at) > 1.second
end
```

---

### ISSUE#245: 対象ページ入力機能

#### データベース
- `book_memos` テーブルに `page_number` カラム（string型、null: true、最大20文字）を追加

#### モデル
- `BookMemo` モデルに `page_number` のバリデーション追加
  - 任意入力（presence: falseでよい）
  - 最大文字数: 20文字

#### コントローラー
- `book_memo_params` に `:page_number` を追加

#### ビュー
- メモ追加フォームに `page_number` 入力フィールドを追加
- 編集フォームにも `page_number` 入力フィールドを追加
- メモタイムラインの表示に `page_number` を追加（入力済みの場合のみ）

---

## ファイル変更一覧

| ファイル | 変更種別 | 内容 |
|---------|---------|------|
| `db/migrate/YYYYMMDDHHMMSS_add_page_number_to_book_memos.rb` | 新規 | page_number カラム追加 |
| `db/schema.rb` | 自動更新 | マイグレーション後に更新 |
| `app/models/book_memo.rb` | 更新 | page_number バリデーション, edited? メソッド追加 |
| `app/controllers/book_memos_controller.rb` | 更新 | edit/update アクション, page_number パラメータ追加 |
| `config/routes.rb` | 更新 | book_memos に :edit, :update 追加 |
| `app/views/book_memos/edit.html.erb` | 新規 | 編集フォーム |
| `app/views/books/show.html.erb` | 更新 | 編集ボタン, 編集時刻表示, page_number 表示 |
| `spec/models/book_memo_spec.rb` | 更新 | page_number バリデーション, edited? テスト |
| `spec/requests/book_memos_spec.rb` | 更新 | edit/update アクション, page_number テスト |
| `spec/factories/book_memos.rb` | 更新 | page_number を追加（デフォルト nil） |
