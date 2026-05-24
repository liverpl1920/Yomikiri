# 設計: 一覧画面で読了本は読了期限ではなく読了日を表示する

## 実装アプローチ

### 変更対象ファイル
- `app/views/books/index.html.erb` — 日付表示ロジックの分岐追加
- `spec/system/books_spec.rb` または `spec/requests/books_spec.rb` — 表示確認テスト追加

### 変更内容

#### index.html.erb
「読了期限」セクションを `book.completed?` で分岐する:

```erb
<%# 読了日 or 読了期限 %>
<div class="book-card__deadline">
  <% if book.completed? %>
    <span class="book-card__deadline-label">読了日</span>
    <span class="book-card__deadline-value">
      <% if book.completed_at.present? %>
        <%= l(book.completed_at.to_date, format: :long) %>
      <% else %>
        未設定
      <% end %>
    </span>
  <% else %>
    <span class="book-card__deadline-label">読了期限</span>
    <span class="book-card__deadline-value">
      <% if book.deadline.present? %>
        <%= l(book.deadline, format: :long) %>
      <% else %>
        未設定
      <% end %>
    </span>
  <% end %>
</div>
```

### テスト方針
- `spec/requests/books_spec.rb` または `spec/system/` に以下を追加:
  - 読了済み本の一覧で「読了日」ラベルが表示されること
  - 読了済み本の一覧で `completed_at` の日付が表示されること
  - 未読/読書中の本は「読了期限」ラベルが引き続き表示されること

## 影響範囲
- 一覧画面の表示のみ。登録・編集・詳細画面には影響なし。
- モデル変更なし。
