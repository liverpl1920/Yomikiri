# 機能設計書: 書籍コピー再登録機能

## 1. コントローラー設計 (`app/controllers/books_controller.rb`)
`new` アクションにおいて、`copy_from_id` パラメータの有無により処理を切り替える。

```ruby
  def new
    if params[:copy_from_id]
      original_book = current_user.books.find_by(id: params[:copy_from_id])
      if original_book
        @book = original_book.dup
        @book.status = :unread
        @book.current_page = 0
        @book.extension_count = 0
        @book.deadline = nil
        @book.completed_at = nil
        @book.memo = nil
        @book.rating = nil
        @book.review = nil
        @book.memo_updated_at = nil
        if original_book.cover_image.attached?
          @book.cover_image.attach(original_book.cover_image.blob)
        end
      else
        @book = current_user.books.build
      end
    else
      @book = current_user.books.build
    end
  end
```

### コピー対象属性とリセット対象属性の整理
- **コピー（引き継ぐ）属性**:
  - `title`, `author`, `genre`, `pages`, `cover_image_url`, `isbn`, `translator`, `publisher`, `cover_image` (Active Storage アタッチメント)
- **リセット（引き継がない）属性**:
  - `status`: `:unread` に変更
  - `current_page`: `0` に変更
  - `extension_count`: `0` に変更
  - `deadline`, `completed_at`, `memo`, `rating`, `review`, `memo_updated_at`: `nil` に設定

### セキュリティおよび堅牢性
- `current_user.books.find_by(id: ...)` を使用し、ログインユーザー以外の書籍情報をコピーできないように制限する。
- 該当書籍が見つからなかった場合（不正なIDなど）、例外を投げずに安全に `current_user.books.build` による通常の新規登録にフォールバックする。

## 2. 画面設計 (`app/views/books/show.html.erb`)
書籍詳細画面のボタン群（アクションエリア）に「この本をもう一度読む」を追加する。

```erb
    <div class="book-show__actions">
      <%= link_to '一覧に戻る', books_path, class: 'btn btn--outline' %>
      <%= link_to 'この本をもう一度読む', new_book_path(copy_from_id: @book.id), class: 'btn btn--secondary' %>
      <%= link_to '書籍情報を編集する', edit_book_path(@book), class: 'btn btn--secondary' %>
      ...
```

デザイン上の整合性：
- 既存の「書籍情報を編集する」ボタンと同様に `btn btn--secondary` クラスを指定し、馴染むデザインにする。
- 配置は「一覧に戻る」の右隣（編集するボタンの左隣）とする。

## 3. テスト設計

### リクエストスペック (`spec/requests/books_spec.rb`)
`GET /books/new` へのテストを追加する。
- `copy_from_id` パラメータが指定され、それが自分の所有する書籍の場合：
  - 各種属性が初期値としてバインドされていることを確認。
  - ステータス、現在ページ、その他のリセット対象属性がリセットされていることを確認。
  - Active Storage の画像アタッチメントが含まれている場合、それがコピー先の書籍にもアタッチされていることを確認。
- `copy_from_id` パラメータが指定されているが、他人の書籍ID、あるいは存在しないIDの場合：
  - 例外が発生せず通常の新規作成画面が読み込まれることを確認。

### システムスペック (`spec/system/books/books_crud_spec.rb`)
- 詳細画面（showビュー）に「この本をもう一度読む」リンクが表示されていることを検証。
- リンクをクリックすると、値が引き継がれた新規作成画面に遷移し、目標読了日を設定して正常に登録できることを検証。
