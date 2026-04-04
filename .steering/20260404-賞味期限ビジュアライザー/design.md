# 設計: 賞味期限ビジュアライザー機能 (Issue #23)

## 既存実装の確認

| 対象 | 実装状況 |
|------|---------|
| `Book#deadline_urgency_class` | ✅ 実装済み（book.rb） |
| CSS urgency クラス定義 | ✅ 実装済み（books.css） |
| W-4 index.html.erb | ✅ 実装済み |
| model スペック | ✅ 実装済み（book_spec.rb） |
| W-6 show.html.erb | ❌ 未実装・書影エリアなし |
| W-6 のリクエストスペック | ❌ 未実装 |

## 実装方針

### show.html.erb への書影エリア追加

`book-show__header` の直前（またはその中）に書影エリア（`.book-show__cover-wrapper`）を追加し、
- `book.deadline_urgency_class` で urgency CSS クラスを適用
- `book.deadline_urgency_class.present?` の場合に緊急バッジを表示

CSS は index.html.erb の `.book-card__cover-wrapper` と同様のパターン。  
ただし show ページ専用のクラス名 `.book-show__cover` / `.book-show__cover-wrapper` / `.book-show__urgency-badge` を使う。

### CSS 追加

`books.css` の `book-show` セクションに:
- `.book-show__cover-wrapper`（position: relative）
- `.book-show__cover`（書影プレースホルダー、緊急度クラスを受け取る）
- `.book-show__urgency-badge`（緊急バッジ）

urgency フィルタークラス（`book-card__cover--urgent-*`）はすでに定義されており、  
要素がどのクラスに属するかに関係なく CSS filter が適用されるため、`book-show__cover` にも流用可能。

### リクエストスペック

`spec/requests/books_spec.rb` の `GET /books/:id` セクションに追加:
- urgency-low（残り7日以下）のバッジが表示されること
- urgency-high（残り1日）のバッジが表示されること
- 読了済みの場合は urgency クラスがないこと
