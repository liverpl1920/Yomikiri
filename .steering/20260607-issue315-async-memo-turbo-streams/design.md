# Issue #315 設計書

## アーキテクチャ方針
Hotwire (Turbo Streams) を使い、コントローラーで `respond_to` ブロックを追加する。
Rails 7 の Turbo Streams 標準パターンに従って実装する。

## 変更点

### コントローラー (`BookMemosController#create`)
```ruby
def create
  @book_memo = @book.book_memos.build(book_memo_params)
  if @book_memo.save
    respond_to do |format|
      format.turbo_stream  # create.turbo_stream.erb を呼ぶ
      format.html { redirect_to @book, notice: "メモを追加しました。" }
    end
  else
    @book_memos = @book.book_memos.latest_first
    @new_book_memo = @book_memo
    prepare_progress_chart_data
    render "books/show", status: :unprocessable_entity
  end
end
```

### Turbo Stream テンプレート (`create.turbo_stream.erb`)
以下の3つの操作を行う:
1. `turbo_stream.append "memo-timeline-list"` — メモリスト末尾に新規メモを追加
2. `turbo_stream.replace "memo-timeline-empty"` — 「まだメモがありません」を非表示にする（または削除）
3. `turbo_stream.replace "new-book-memo-form"` — フォームをリセット（空の新規メモで再描画）

### メモパーシャル (`_book_memo.html.erb`)
`show.html.erb` の各メモ `<li>` 部分をパーシャルに切り出す。

### ビュー修正 (`books/show.html.erb`)
- メモフォームを `turbo_frame_tag` または `id` 付きの div でラップ: `id="new-book-memo-form"`
- メモリスト `<ul>` に `id="memo-timeline-list"` を付与
- 「まだメモがありません」の `<p>` に `id="memo-timeline-empty"` を付与
- フォームの `data: { turbo: false }` を削除（Turbo を有効化）

## フォームリセット方針
`turbo_stream.replace "new-book-memo-form"` で空の `@new_book_memo = BookMemo.new` を使ってフォームを再描画する。
コントローラーで成功後に `@new_book_memo = @book.book_memos.build` を設定してテンプレートに渡す。

## エラーハンドリング
バリデーションエラー時は `render "books/show", status: :unprocessable_entity` のまま変更なし。
エラー時は HTML リクエストとして扱われ、フルページレンダリングされる（既存と同一）。
