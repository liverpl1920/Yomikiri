# 設計ドキュメント: Issue #287 メモ検索機能

## アーキテクチャ方針
既存の本の一覧検索と同じパターンに倣いつつ、「メモ一覧」という別の表示形式を追加する。

## UI/UX 設計

### 表示切り替え
- 現在の検索フォームは本の属性（タイトル、著者等）を検索するもの
- メモ検索は別のフォームとして一覧上部に追加
- `memo_keyword` パラメータが存在する場合にメモ一覧を表示（本の一覧の代わり）
- `memo_keyword` がない場合は従来通り本の一覧を表示

### メモ一覧の表示
各メモカードに以下を表示：
- 所属する本のタイトル（`books#show` へのリンク）
- ページ番号（あれば）
- メモ内容（既存の装飾レンダリングを利用）
- 作成日時（`l(memo.created_at, format: :long)`）

## モデル設計

### BookMemo スコープ追加
```ruby
scope :content_like, ->(query) { where("content ILIKE ?", "%#{sanitize_sql_like(query)}%") }
```

## コントローラー設計

### BooksController#index の変更
```ruby
def index
  @search_params = build_search_params(params)
  @search_active = @search_params.values.any?(&:present?)

  if params[:memo_keyword].present?
    # メモ検索モード
    @memo_keyword = params[:memo_keyword]
    @memo_search_active = true
    book_ids = current_user.books.ids
    @memos = BookMemo.where(book_id: book_ids)
                     .content_like(@memo_keyword)
                     .includes(:book)
                     .order(created_at: :desc)
    @books = current_user.books.none  # 本の一覧は表示しない
  else
    # 通常の本の一覧モード
    @memo_keyword = nil
    @memo_search_active = false
    @memos = []
    @books = current_user.books.filtered_for_index(@search_params)
  end
end
```

## ビュー設計

### index.html.erb への追加
1. メモ検索フォーム（既存の本の検索フォームの下に追加）
2. メモ一覧パーシャルの呼び出し（`@memo_search_active` が true の場合）

### _memo_search_results.html.erb
メモカードの一覧を表示するパーシャル。

## CSS 設計（BEM）

```css
.memo-list { }
.memo-list__item { }
.memo-card { }
.memo-card__book-title { }
.memo-card__page-number { }
.memo-card__content { }
.memo-card__meta { }
```

## セキュリティ考慮事項
- `current_user.books.ids` で自分の本のみを検索対象にすることで、他ユーザーのメモにアクセスされない
- `sanitize_sql_like` で SQLインジェクション対策
- メモ内容の表示は既存の `render_memo_content` ヘルパーを流用（XSS対策済み）
