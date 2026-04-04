# 設計書

## アーキテクチャ概要

Rails の ERB ビューテンプレート修正のみ。コントローラー・モデル・ルートに変更なし。

## コンポーネント設計

### 1. `app/views/books/index.html.erb`

**責務**:
- 積読一覧を表示する
- 書籍登録画面へのナビゲーションを提供する

**修正点**:
- ヘッダーの `<button disabled>` → `<%= link_to "...", new_book_path, class: "..." %>`
- Empty State の `<button disabled>` → `<%= link_to "...", new_book_path, class: "..." %>`

## データフロー

### ボタンクリック操作
```
1. ユーザーが「+ 本を追加する」または「最初の本を登録して始める」をクリック
2. link_to により GET /books/new へ遷移
3. BooksController#new がレンダリング
```

## テスト戦略

### リクエストスペック
- `GET /books` で正常レスポンス（200 OK）を確認
- レスポンスに `new_book_path` へのリンクが存在することを確認
- `disabled` 属性が存在しないことを確認

## ディレクトリ構造

```
app/views/books/
  index.html.erb   ← 修正対象（2箇所）

spec/requests/
  books_spec.rb    ← テスト対象（既存）
```

## 実装の順序

1. `app/views/books/index.html.erb` のヘッダーボタンを `link_to` に変更
2. `app/views/books/index.html.erb` の Empty State ボタンを `link_to` に変更
3. RSpec でテスト確認
4. RuboCop 確認
