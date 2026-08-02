# 設計書

## アーキテクチャ概要

本機能は、Railsの標準的なM-C-VパターンおよびActiveRecordのコールバックを活用して実装します。

```
[BooksController#new]
   | (params[:copy_from_id] があれば)
   v
[original_book の dup & read_count+1 & タイトルにプレフィックス付与]
   |
   v
[新規登録画面 (ビューに表示)]
   | (ユーザーが登録ボタン押下)
   v
[BooksController#create]
   |
   v
[Book モデルの保存 & before_save コールバックで status=completed 時の read_count 制御]
   |
   v
[DB (books テーブル)]
```

## コンポーネント設計

### 1. データベース (マイグレーション)

**実装の要点**:
- `books` テーブルに `read_count` カラムを追加します。
  - 型: `integer`
  - デフォルト値: `0`
  - `null: false`
- 既存データの移行処理を行います。
  - `completed?` の本は `read_count` を `1` 以上に設定します。
  - 同一 `normalized_title` の本が複数ある場合は、古い本から順に `read_count = 1, 2, 3...` を割り当てます。
  - `completed?` 以外の本は `read_count` を `0` に設定します。

### 2. `Book` モデル (`app/models/book.rb`)

**責務**:
- タイトルの正規化 (`normalize_title`) 時、先頭のプレフィックス `【N度目】` を除去してから正規化する。
- 保存時、ステータスが `completed` であれば `read_count` が `0` の場合に `1` に自動設定する。
- 表示タイトル (`display_title`) は、DBに保存されたタイトルをそのまま返す。

**実装の要点**:
- `.normalize_title(val)` の正規表現によるプレフィックス除去:
  ```ruby
  def self.normalize_title(val)
    # 先頭の「【N度目】」プレフィックスを除去
    clean = val.to_s.gsub(/\A【\d+度目】/, "")
    clean.unicode_normalize(:nfkc).gsub(/[[:space:]]+/, " ").strip.downcase
  end
  ```
- コールバックの実装:
  ```ruby
  before_save :set_initial_read_count_on_completion

  private

  def set_initial_read_count_on_completion
    if completed? && read_count.zero?
      self.read_count = 1
    end
  end
  ```
- `display_title` の修正:
  ```ruby
  def display_title
    title
  end
  ```

### 3. `BooksController` (`app/controllers/books_controller.rb`)

**責務**:
- 「もう一度読む」遷移時 (`new` アクションで `copy_from_id` がある場合) に、コピー元の `read_count` をカウントアップし、プレフィックスを付与したタイトルを設定する。

**実装の要点**:
- `new` アクションの修正:
  ```ruby
  def new
    if params[:copy_from_id]
      original_book = current_user.books.find_by(id: params[:copy_from_id])
      if original_book
        @book = original_book.dup
        @book.read_count = original_book.read_count + 1
        clean_title = original_book.title.gsub(/\A【\d+度目】/, "")
        if @book.read_count >= 2
          @book.title = "【#{@book.read_count}度目】#{clean_title}"
        else
          @book.title = clean_title
        end
        @book.status = :unread
        @book.current_page = 0
        @book.extension_count = 0
        @book.deadline = nil
        @book.completed_at = nil
        @book.memo = nil
        @book.rating = nil
        @book.review = nil
        @book.memo_updated_at = nil
        if original_book.cover_image.attached?
          @book.cover_image.attach(original_book.cover_image.blob)
        end
      else
        @book = current_user.books.build
      end
    else
      @book = current_user.books.build
    end
  end
  ```

## テスト戦略

### ユニットテスト (`spec/models/book_spec.rb`)
- `.normalize_title` が `【N度目】` を除去した上で正規化することを確認。
- `before_save` で `status` が `completed` になった際に `read_count` が `0` から `1` に設定されることを確認。
- `display_title` がDBに保存されたタイトルそのものを返すことを確認（既存の `(N回目)` テストを修正）。

### 統合テスト (`spec/requests/books_spec.rb` & `spec/system/books/books_crud_spec.rb`)
- `copy_from_id` を渡して `new` 画面に遷移した際、タイトルが `【2度目】元のタイトル` になり、`read_count` が `2` になっていることを確認。
- 再読本をそのまま登録・保存し、正しく一覧や詳細画面で表示できることを確認。
- 複数冊の再読本が存在する場合に、詳細画面の「前回（N回目）の読書記録はこちら」リンクが正しい書籍レコードを指していることを確認。
