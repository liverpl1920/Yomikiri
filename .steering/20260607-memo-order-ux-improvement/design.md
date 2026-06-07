# 設計書

## アーキテクチャ概要

本機能は、Rails 7 の Hotwire（Turbo Streams）を用いたリアルタイムのDOM操作を利用して実装されています。
メモ作成時にサーバーが `turbo_stream` フォーマットのHTMLを返し、フロントエンドがそれを受け取って特定のDOM要素に対して操作を行います。

### データフロー
```
[User] -> (新規メモ入力) -> [Submit]
   |
   +--> POST /books/:book_id/book_memos (BookMemosController#create)
         |
         +--> [Server] DBに保存 -> 成功
         |       |
         |       +--> render create.turbo_stream.erb
         |               |
         |               +--> (DOM操作) prepend "memo-timeline-list" with new memo HTML
         |               +--> (DOM操作) remove "memo-timeline-empty"
         |               +--> (DOM操作) replace "new-book-memo-form" with fresh form HTML
         |
[User View] <-- (自動的に先頭に表示が追加される)
```

## コンポーネント設計

### 1. View / Turbo Stream (`app/views/book_memos/create.turbo_stream.erb`)

**責責**:
- 新規メモが正常に作成された後、フロントエンドのDOMを更新する。

**実装の要点**:
- メモを降順（最新が上）で並べるため、`append` ではなく `prepend` を用いて、`#memo-timeline-list` の先頭に新規メモを挿入する。
- 変更前:
  ```erb
  <%= turbo_stream.append "memo-timeline-list" do %>
    <%= render partial: 'book_memos/book_memo', locals: { book_memo: @book_memo, book: @book } %>
  <% end %>
  ```
- 変更後:
  ```erb
  <%= turbo_stream.prepend "memo-timeline-list" do %>
    <%= render partial: 'book_memos/book_memo', locals: { book_memo: @book_memo, book: @book } %>
  <% end %>
  ```

### 2. Controller (`app/controllers/books_controller.rb`, `app/controllers/book_memos_controller.rb`)

**責責**:
- 初期表示（`books#show`）の際、メモを `created_at: :desc` の順でロードしてビューに渡す。
- メモ作成失敗時の再レンダリング時（`book_memos#create` の `else` 節）に、メモを `created_at: :desc` の順でロードしてビューに渡す。

**実装の要点**:
- 現在すでに `BookMemo.latest_first` スコープを使って `@book_memos = @book.book_memos.latest_first` として取得しているため、コントローラーの変更は不要です。既存の実装で初期表示時の降順ソートは保証されています。

## テスト戦略

### 統合テスト (System Spec / Request Spec)
- `spec/requests/book_memos_spec.rb` 内に Turbo Streams のテストがあります。今回の Turbo Streams のアクションが `append` から `prepend` に変わることにより、既存のテストに影響がないか確認します。
- 必要に応じて、新規メモ追加時に先頭に追加される挙動をテストする System Spec を `spec/system/books/detail_ui_states_spec.rb` または `spec/system/books/memos_spec.rb` などに実装する、または既存の spec に追加します。

## ディレクトリ構造

```text
app/
  controllers/
    book_memos_controller.rb (確認のみ、変更なし)
    books_controller.rb      (確認のみ、変更なし)
  views/
    book_memos/
      create.turbo_stream.erb (変更対象)
```

## 実装の順序

1. `app/views/book_memos/create.turbo_stream.erb` の `append` を `prepend` に修正。
2. RSpec テストの実行と必要に応じたテストコードの更新。
