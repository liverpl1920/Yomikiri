# 設計: 積読詳細表示機能 (Issue #16)

## 変更ファイル一覧
1. `app/views/books/show.html.erb` - 詳細表示の拡充
2. `app/views/books/index.html.erb` - カードをリンク化
3. `app/assets/stylesheets/books.css` - book-show CSS追加
4. `spec/requests/books_spec.rb` - showアクションのテスト拡充

## show.html.erb 設計
現状に以下を追加:
- ステータスバッジ（未読/読書中/読了）
- 進捗プログレスバー（`role="progressbar"` アクセシブル実装）
- 残ページ数（`@book.remaining_pages`）
- 延長回数（`@book.extension_count`）
- 「今日のノルマ」は削除（後続Issueで実装）

## index.html.erb 変更
- book-cardに `aria-disabled="true"` が付いていたのを `link_to` に変更
- コメントにあった「Issue #16実装後に変更」の指示に従う

## CSS設計
`.book-show` コンポーネントのスタイルを `books.css` に追加:
- ヘッダー（タイトル・著者・ステータスバッジ）
- 詳細グリッド（dt/dd リスト）
- プログレスバー（`book-card__progress-bar-wrapper`と同じ実装）
- アクションボタン

## 認可
- `set_book` で `current_user.books.find_by` を使用済み → 他ユーザーの書籍は404応答
- 認証は `before_action :authenticate_user!` で担保済み
