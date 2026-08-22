# 本詳細画面ボタン配置改善設計書

## 設計方針
`app/views/books/show.html.erb` 内の `book-show__actions` の構造を機能ごとのグループ構造に改修し、`app/assets/stylesheets/books.css` にてスタイリングを行います。

## HTML構造
```erb
<div class="book-show__actions">
  <div class="book-show__actions-group">
    <%= link_to '一覧に戻る', books_path, class: 'btn btn--outline' %>
    <%= link_to '書籍情報を編集する', edit_book_path(@book), class: 'btn btn--outline' %>
  </div>
  
  <div class="book-show__actions-group">
    <%= link_to 'この本をもう一度読む', new_book_path(copy_from_id: @book.id), class: 'btn btn--primary' %>
    <% unless @book.completed? || @book.retired? || @book.deadline.nil? %>
      <button type="button" class="btn btn--primary" data-action="click->modal#openExtend">
        期限を延長する
      </button>
    <% end %>
    <% unless @book.completed? || @book.retired? || (@book.unread? && @book.deadline.nil?) %>
      <button type="button" class="btn btn--outline" data-action="click->modal#openRetire">
        リタイアする
      </button>
    <% end %>
  </div>

  <div class="book-show__actions-group book-show__actions-group--danger">
    <button type="button" class="btn btn--danger-ghost" data-action="click->modal#open">
      削除する
    </button>
  </div>
</div>
```

## CSS設計
```css
.book-show__actions {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-md);
}

.book-show__actions-group {
  display: flex;
  flex-wrap: wrap;
  gap: var(--spacing-sm);
  align-items: center;
}

@media (max-width: 640px) {
  .book-show__actions-group {
    flex-direction: column;
    align-items: stretch;
  }

  .book-show__actions-group .btn {
    width: 100%;
  }
}
```
