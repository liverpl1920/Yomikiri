# 設計: 進捗更新機能 (Issue #19)

## アプローチ概要

Rails の `member` ルートに `PATCH /books/:id/update_progress` を追加し、
BooksController に `update_progress` アクションを実装する。
ビューには進捗更新フォームを追加し、Stimulus コントローラーでインタラクションを実装する。

## ルーティング

```ruby
resources :books, only: [...] do
  member do
    patch :update_progress
  end
end
```

## コントローラー設計

```ruby
# app/controllers/books_controller.rb
before_action :set_book, only: [:show, :destroy, :update_progress]

def update_progress
  pages_read = params[:pages_read].to_i
  new_page   = @book.current_page + pages_read
  new_page   = new_page.clamp(0, @book.target_pages)

  if @book.update(current_page: new_page)
    redirect_to @book, notice: "進捗を更新しました。"
  else
    render :show, status: :unprocessable_entity
  end
end
```

「現在ページを直接入力」の場合は `pages_read` ではなく `current_page` パラメータを使用するため、
両方を受け取れるように設計する。

実際には `update_progress` アクションのパラメータは:
- `pages_read`: 今日読んだページ数（加算用）
- `direct_page`: 指定する場合は直接ページ番号（上書き用）

どちらか一方が送られる。`pages_read` を優先する。

## ビュー設計

`app/views/books/show.html.erb` に進捗更新セクションを追加:

```
[今日読んだページ数フォーム]
  - マイナスボタン | 数値入力 | プラスボタン
  - 「更新する」ボタン

[▼ 現在ページを直接入力] (折りたたみ)
  - 数値入力
  - 「更新する」ボタン
```

## Stimulus コントローラー

`app/javascript/controllers/progress_update_controller.js` を新規作成:
- ±ボタンでページ数の増減
- 0未満・target_pages 超過を防止
- 折りたたみの開閉制御

## バリデーション

Book モデルに既存バリデーション:
```ruby
validate :current_page_not_exceed_target_pages
```
これをそのまま活用する（コントローラー側でも clamp で防御的に制限）。

## テスト方針

`spec/requests/books_spec.rb` に以下を追加:
- 有効な pages_read で current_page が加算される
- pages_read が target_pages を超える場合は clamp される（または バリデーションエラー）
- 未認証ユーザーはリダイレクト
- 他ユーザーの書籍は 404

## CSS

`app/assets/stylesheets/books.css` に `book-show__progress-update` ブロックのスタイルを追加。
