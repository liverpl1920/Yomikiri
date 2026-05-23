# 設計書: 登録済み書籍情報を編集できるようにする (ISSUE#212)

## 実装方針
既存の `_form.html.erb` パーシャルを最大限に活用し、最小限の変更で編集機能を実装する。

## 変更ファイル一覧

| ファイル | 変更種別 | 内容 |
|---------|---------|------|
| `config/routes.rb` | 修正 | `resources :books` に `:edit, :update` を追加 |
| `app/controllers/books_controller.rb` | 修正 | `edit`, `update` アクション追加、`before_action` に追加、`edit_book_params` 追加 |
| `app/views/books/edit.html.erb` | 新規 | 編集画面テンプレート |
| `app/views/books/_form.html.erb` | 修正 | `is_past_reading`・`completed_at_input` を `new_record?` 時のみ表示 |
| `app/views/books/show.html.erb` | 修正 | 書籍詳細画面に「書籍情報を編集する」リンクを追加 |
| `spec/requests/books_spec.rb` | 修正 | `edit`・`update` アクションのテストケース追加 |

## コントローラー設計

```ruby
# before_action
before_action :set_book, only: [ :show, :destroy, :update_progress, :update_memo, :complete, :change_deadline, :update_review, :edit, :update ]

# editアクション
def edit
end

# updateアクション
def update
  if @book.update(edit_book_params)
    redirect_to @book, notice: "#{@book.title}の情報を更新しました。"
  else
    render :edit, status: :unprocessable_entity
  end
end

# edit_book_paramsメソッド（privateセクション）
def edit_book_params
  params.require(:book).permit(:title, :author, :genre, :total_pages, :target_pages, :deadline, :cover_image_url)
end
```

## ルーティング設計
```ruby
resources :books, only: [ :index, :new, :create, :show, :destroy, :edit, :update ] do
  ...
end
```

## ビュー設計
- `edit.html.erb`: `new.html.erb` に倣い、見出しを「書籍情報を編集する」にする
- `_form.html.erb`: `is_past_reading` / `completed_at_input` セクションを `if book.new_record?` でガード
- `show.html.erb`: `book-show__actions` div 内に `edit_book_path(@book)` リンクを追加
