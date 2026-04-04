# 設計: 読了機能

## アーキテクチャ方針

既存の Rails MVC パターンに従い、BooksController に `complete` アクションを追加する。

## データフロー

```
ユーザー → 「読了にする！」ボタンクリック
→ PATCH /books/:id/complete
→ BooksController#complete
→ book.update(status: :completed, completed_at: Time.current)
→ redirect_to book_path(@book) with flash[:completed_book]
→ show.html.erb で flash を検出し、読了モーダルを自動表示
```

## ルーティング

```ruby
resources :books do
  member do
    patch :update_progress
    patch :complete  # 追加
  end
end
```

## コントローラ変更

`BooksController` に以下を追加:

```ruby
before_action :set_book, only: [:show, :destroy, :update_progress, :complete]

def complete
  if @book.update(status: :completed, completed_at: Time.current)
    flash[:completed_book] = @book.title
    redirect_to @book
  else
    render :show, status: :unprocessable_entity
  end
end
```

## ビュー変更

### show.html.erb

1. **「読了にする！」ボタン**: 未完了時に表示。progress_percentage == 100 の場合は強調CSSクラスを追加。
2. **読了お祝いモーダル（W-13）**: flash[:completed_book] が存在する場合、初期表示を visible にする。
   - `data-modal-target="overlay"` の `hidden` 属性を外す

### index.html.erb

読了済み書籍のカードに視覚的な区別クラスを追加（CSS opacity/グレースケール）。

## モーダル表示戦略

- flash[:completed_book] をセット
- show.html.erb で flash の有無を検出
- モーダルの hidden 属性を `flash[:completed_book].present?` であれば外す（= 自動表示）
- JavaScript 不要のシンプルな実装

## CSS 追加

- `.book-show__complete-btn` - 読了ボタン
- `.book-show__complete-btn--highlighted` - 100%時の強調スタイル
- `.book-card--completed` - 読了済み書籍カードのスタイル
- `.celebration-modal__*` - 読了お祝いモーダル

## 既存バグ修正

`show.html.erb` に孤立した重複HTMLが存在（lines 213-276）。修正する。
