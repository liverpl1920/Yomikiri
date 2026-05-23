# 設計: 読了完了画面で評価・感想入力を追加 (ISSUE#197)

## 実装アプローチ

### データモデル変更

`books` テーブルに2カラムを追加:

| カラム名 | 型 | 制約 | 説明 |
|---------|---|------|------|
| `rating` | integer | null: true | 評価（1〜5） |
| `review` | text | null: true | 感想 |

### バリデーション (Book モデル)

```ruby
validates :rating, numericality: { in: 1..5, only_integer: true }, allow_nil: true
validates :review, length: { maximum: 1000 }, allow_blank: true
```

### コントローラー変更 (BooksController)

- `before_action :set_book` に `:update_review` を追加
- `update_review` アクション追加:
  ```ruby
  def update_review
    if @book.update(review_params)
      redirect_to @book, notice: "評価・感想を保存しました。"
    else
      render :show, status: :unprocessable_entity
    end
  end
  ```
- `review_params` プライベートメソッド追加

### ルーティング (routes.rb)

```ruby
member do
  patch :update_review
end
```

### ビュー変更 (show.html.erb)

読了済み（`@book.completed?`）の場合のみ評価・感想セクションを表示:
- ★ラジオボタン（1〜5）で評価入力
- テキストエリアで感想入力
- 保存ボタン

## ファイル変更一覧

1. `db/migrate/[timestamp]_add_rating_and_review_to_books.rb` (新規)
2. `app/models/book.rb` (変更: バリデーション追加)
3. `app/controllers/books_controller.rb` (変更: update_reviewアクション追加)
4. `config/routes.rb` (変更: update_reviewルート追加)
5. `app/views/books/show.html.erb` (変更: 評価・感想セクション追加)
6. `app/assets/stylesheets/books.css` (変更: スタイル追加)
7. `spec/requests/books_spec.rb` (変更: update_review のテスト追加)
8. `spec/models/book_spec.rb` (変更: ratingバリデーションテスト追加)
