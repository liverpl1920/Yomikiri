# タスクリスト: 登録済み書籍情報を編集できるようにする (ISSUE#212)

## タスク

- [x] T1: `config/routes.rb` に `:edit, :update` を追加
- [x] T2: `BooksController` に `edit`・`update` アクションと `edit_book_params` を追加
- [x] T3: `app/views/books/edit.html.erb` を新規作成
- [x] T4: `app/views/books/_form.html.erb` を修正（`is_past_reading`・`completed_at_input` を new_record? 時のみ表示）
- [x] T5: `app/views/books/show.html.erb` に「書籍情報を編集する」ボタンを追加
- [x] T6: `spec/requests/books_spec.rb` に `edit`・`update` アクションのテストを追加
