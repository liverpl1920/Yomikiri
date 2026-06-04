# 設計書 (Issue #291)

## 修正方針

### 1. 詳細画面のTurboキャッシュ制御の追加
詳細画面（`app/views/books/show.html.erb`）の `content_for :head` に、プレビューキャッシュを無効化する `meta` タグを追加します。
これにより、詳細画面に戻った時や他の画面から遷移した時に、古い評価や古い進捗状態のプレビューが表示されるのを防ぎます。

```erb
<% content_for :head do %>
  <meta name="turbo-cache-control" content="no-cache">
  <%# 既存の script 等があれば残す %>
<% end %>
```

### 2. 評価・感想保存後のリダイレクト先とステータスの変更
`BooksController#update_review` アクションで、更新成功時のリダイレクト先を以下のように制御します。
- `params[:redirect_to] == 'index'` の場合は `books_path`（一覧画面）へリダイレクト。
- それ以外（デフォルト）の場合は `@book`（詳細画面）へリダイレクト。
- Turbo DriveがPATCHリクエスト後のリダイレクトを正常に追従できるように、リダイレクト時に `status: :see_other` (303 See Other) を明示します。

```ruby
  def update_review
    if @book.update(review_params)
      redirect_target = params[:redirect_to] == 'index' ? books_path : book_path(@book)
      redirect_to redirect_target, notice: "評価・感想を保存しました。", status: :see_other
    else
      prepare_show_vars
      render :show, status: :unprocessable_entity
    end
  end
```

### 3. ビュー側のフォーム修正
`app/views/books/show.html.erb` の「読了お祝いモーダル」内のフォームに、隠しパラメータとして `redirect_to` を追加します。

```erb
<%= form_with model: @book, url: update_review_book_path(@book), method: :patch, class: 'celebration-modal__review-form', data: { turbo: false } do |f| %>
  <%= hidden_field_tag :redirect_to, 'index' %>
  ...
```

詳細画面内の「評価・感想」フォームには `redirect_to` は指定しません（デフォルトで詳細画面に留まる）。

### 4. テストの修正・追加
- `spec/requests/books_spec.rb` の `PATCH /books/:id/update_review` のリダイレクト先の期待値を修正します。
  - 通常の更新時は `book_path(book)` へリダイレクトすることを確認する。
  - `params[:redirect_to] = 'index'` を付与した時は `books_path` へリダイレクトすることを確認する。
- `spec/system/books/review_spec.rb` に、詳細画面のフォームから評価・感想を更新して詳細画面に留まること、および表示が即座に更新されることを確認するシステムテストを追加します。
