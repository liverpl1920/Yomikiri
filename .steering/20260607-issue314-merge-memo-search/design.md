# Issue #314: 設計メモ

## 検索ロジック設計

### 統合クエリの方針

メモキーワードを含む検索の場合：

```ruby
# コントローラー側
@search_params = normalized_index_search_params  # :memo_keyword も含む
@books = current_user.books.with_attached_cover_image.filtered_for_index(@search_params)

# モデル側（Book.filtered_for_index）
if params[:memo_keyword].present?
  memo_book_ids = BookMemo.where(book_id: scope.select(:id))
                          .content_like(params[:memo_keyword])
                          .select(:book_id)
  relation = relation.where(id: memo_book_ids)
end
```

メモキーワードと他の条件（タイトル等）を同時に指定した場合の挙動：
- **AND 結合**：タイトル条件にマッチし、かつメモ内容にマッチする本のみを返す

この方針は Issue のヒントに合致している（「メモの条件をORで追加」というヒントもあるが、UIを1つにまとめるシンプルさを優先する）。

## UI変更

既存の本の検索フォームのフィールド群に「メモ内容」欄を追加する。
独立したメモ検索フォームを削除する。

## 削除するロジック

- `@memo_keyword = params[:memo_keyword].presence`
- `@memo_search_active = @memo_keyword.present?`
- `if @memo_search_active` 分岐
- `_memo_search_results.html.erb` パーシャルへのレンダリング
