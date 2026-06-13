# Issue #359 設計

## ボタン役割マッピング

| ボタン名 | 現在のスタイル | 変更後のスタイル | 理由 |
|---|---|---|---|
| 一覧に戻る | `btn--outline` | `btn--ghost`（テキストリンク系） | 補助的な移動のみ |
| この本をもう一度読む | `btn--secondary` | `btn--primary` | 読了後の主要アクション |
| 書籍情報を編集する | `btn--secondary` | `btn--outline` | 補助的な操作 |
| 期限を延長する | `btn--secondary` | `btn--primary` | 読書中の主要アクション |
| 削除する | `btn--danger` | `btn--danger-ghost` | 破壊的操作は目立たせない |

## CSS 変更

### application.css に追加
```css
.btn--danger-ghost {
  background-color: transparent;
  color: var(--color-danger);
  border-color: var(--color-danger);
}

.btn--danger-ghost:hover {
  background-color: rgba(166, 58, 80, 0.08);
  border-color: var(--color-danger);
  text-decoration: none;
}
```

### btn--ghost（一覧に戻るリンク用）
「一覧に戻る」は link_to なので `btn--ghost` または `btn--link` クラスを用意するか、
既存の `btn--outline` に留めてもよい。

→ 「一覧に戻る」は `btn--outline` のまま（十分に補助的）
→ ただしグループ内での配置順序を調整し、削除ボタンとの視覚的距離を意識する

## ERB 変更（show.html.erb 461〜475行目）

```erb
<div class="book-show__actions">
  <%= link_to '一覧に戻る', books_path, class: 'btn btn--outline' %>
  <%= link_to 'この本をもう一度読む', new_book_path(copy_from_id: @book.id), class: 'btn btn--primary' %>
  <%= link_to '書籍情報を編集する', edit_book_path(@book), class: 'btn btn--outline' %>
  <% unless @book.completed? || @book.deadline.nil? %>
    <button type="button" class="btn btn--primary"
            data-action="click->modal#openExtend">
      期限を延長する
    </button>
  <% end %>
  <button type="button" class="btn btn--danger-ghost"
          data-action="click->modal#open">
    削除する
  </button>
</div>
```

## 注意事項
- 「この本をもう一度読む」は常に表示（読了前後問わず）なので Primary に変更
- 「期限を延長する」は読了前 & 期限設定済みのみ表示なので Primary に変更
- 上記2つが同時に表示されることはない（読了後は期限延長ボタンが非表示）
- モーダル内の「削除する」ボタンは `btn--danger` のままとする（モーダルのコンテキストでは明確な確認アクション）
