# Issue #322: 設計メモ

## 検索ロジック設計

### 1. モデル側 (`Book.filtered_for_index`)

現在、`filtered_for_index` 内で `params[:memo_keyword]` を使った絞り込みが行われているが、これを削除する。
これにより、本の検索条件（タイトル、著者等）による本の一覧の絞り込みと、メモのキーワードによるメモの絞り込みを分離する。

```ruby
# app/models/book.rb
  def self.filtered_for_index(params)
    relation = for_index_list
    relation = relation.title_like(params[:title]) if params[:title].present?
    relation = relation.author_like(params[:author]) if params[:author].present?
    relation = relation.genre_like(params[:genre]) if params[:genre].present?
    relation = relation.publisher_like(params[:publisher]) if params[:publisher].present?
    relation = relation.translator_like(params[:translator]) if params[:translator].present?
    relation = relation.completed_from(params[:completed_from]) if params[:completed_from].present?
    relation = relation.completed_to(params[:completed_to]) if params[:completed_to].present?
    # params[:memo_keyword] による絞り込みは削除
    relation
  end
```

### 2. コントローラー側 (`BooksController#index`)

検索のパラメータに基づいて、`@books` と `@memos` を取得し分ける。

- 本に関する検索パラメータ：`[:title, :author, :genre, :publisher, :translator, :completed_from, :completed_to]`
- メモに関する検索パラメータ：`[:memo_keyword]`

```ruby
# app/controllers/books_controller.rb
  def index
    @search_params = normalized_index_search_params
    @search_active = @search_params.values.any?(&:present?)

    book_search_keys = [:title, :author, :genre, :publisher, :translator, :completed_from, :completed_to]
    book_search_active = @search_params.slice(*book_search_keys).values.any?(&:present?)

    if @search_active
      if book_search_active
        # 本の検索条件が指定されている場合は、本を検索
        @books = current_user.books.with_attached_cover_image.filtered_for_index(@search_params)
      else
        # メモの検索条件のみの場合は、本の一覧は表示しない
        @books = Book.none
      end

      if @search_params[:memo_keyword].present?
        # メモキーワードが指定されている場合
        if book_search_active
          # 本の検索条件に一致した本に紐づくメモに絞り込む
          book_ids = @books.pluck(:id)
          @memos = current_user.book_memos.includes(:book).joins(:book)
                               .where(book_id: book_ids)
                               .content_like(@search_params[:memo_keyword])
                               .latest_first
        else
          # 本の検索条件がない場合は、全本から検索
          @memos = current_user.book_memos.includes(:book).joins(:book)
                               .content_like(@search_params[:memo_keyword])
                               .latest_first
        end
      else
        @memos = BookMemo.none
      end
    else
      # 初期表示
      @books = current_user.books.with_attached_cover_image.filtered_for_index(@search_params)
      @memos = BookMemo.none
    end
  end
```

### 3. ビュー側 (`app/views/books/index.html.erb`)

本の検索結果エリアとは別に、メモの検索結果エリアを追加する。

```erb
<% if @memos.present? %>
  <div class="memo-search-results">
    <h2 class="memo-search-results__title">メモの検索結果 (<%= @memos.count %>件)</h2>
    <ul class="memo-timeline__list" aria-label="メモの検索結果一覧">
      <% @memos.each do |memo| %>
        <li class="memo-timeline__item">
          <div class="memo-timeline__header">
            <div class="memo-timeline__timestamps">
              <%= link_to memo.book.title, book_path(memo.book, anchor: dom_id(memo)), class: "memo-search-results__book-title" %>
              <span class="memo-timeline__date">作成：<%= l(memo.created_at, format: :default) %></span>
            </div>
          </div>
          <% if memo.page_number.present? %>
            <div class="memo-timeline__page">
              <span class="memo-timeline__page-label">対象ページ：</span>
              <span class="memo-timeline__page-value"><%= memo.page_number %></span>
            </div>
          <% end %>
          <div class="memo-timeline__body">
            <%= render_book_memo_content(memo.content) %>
          </div>
          <div class="memo-search-results__actions">
            <%= link_to "本の該当箇所へ", book_path(memo.book, anchor: dom_id(memo)), class: "btn btn--secondary btn--sm" %>
          </div>
        </li>
      <% end %>
    </ul>
  </div>
<% end %>
```

## CSS設計 (`app/assets/stylesheets/books.css`)

メモ検索結果表示用のスタイルを `.memo-search-results` 等のBEM命名規則で追加する。
- `.memo-search-results` : コンテナ
- `.memo-search-results__title` : タイトル
- `.memo-search-results__book-title` : 紐づく書籍名へのリンク（ホバーでアンダーラインなどの装飾）
- `.memo-search-results__actions` : 「本の該当箇所へ」ボタンを配置するエリア

CSSデザインは、他のページのタイムライン等の既存のクラス (`.memo-timeline`) のスタイルをできる限り再利用し、調和のとれたデザインにする。
また、本が空でメモだけがある場合等のレイアウト崩れを防ぐ。
