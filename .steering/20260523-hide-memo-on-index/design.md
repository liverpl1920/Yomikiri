# 設計: 一覧ページでメモ欄を表示しないようにする

## 実装方針
`app/views/books/index.html.erb` のブックカード内、メモを条件付きで表示している以下の3行を削除する。

```erb
<% if book.memo.present? %>
  <p class="book-card__memo"><%= truncate(book.memo.to_s.gsub(/\s+/, ' '), length: 60) %></p>
<% end %>
```

## 影響範囲
- `app/views/books/index.html.erb` — 変更あり（3行削除）
- `app/views/books/show.html.erb` — 変更なし（詳細ページではメモを引き続き表示）
- CSS (`book-card__memo`) — 削除しない（将来的に再利用の可能性あり、孤立したスタイルとして残置）

## テスト方針
- 既存の system spec / request spec をそのまま実行して回帰なしを確認
- メモ表示に関する spec がある場合は index ページで非表示であることを確認
