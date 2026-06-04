# 設計書

## アーキテクチャ概要

Railsの Concern パターンを採用し、`BooksController` と `BookMemosController` の間で重複しているグラフデータ準備の共通処理を共通化します。

```
┌─────────────────┐       ┌───────────────────────┐
│ BooksController │ ───>  │                       │
└─────────────────┘       │ ProgressChartPreparable │
                          │ (Concern)             │
┌───────────────────────┐ │                       │
│ BookMemosController   │ ───>  │                       │
└───────────────────────┘ └───────────────────────┘
```

## コンポーネント設計

### 1. ProgressChartPreparable (Concern)

**型**: `app/controllers/concerns/progress_chart_preparable.rb`

**責務**:
- 読書進捗グラフ描画用のデータ (`@progress_chart_data`) を準備する。
- グラフの最大値 (`@progress_chart_max_pages`) を書籍の総ページ数 (`@book.pages`) に固定して設定する。

**実装の要点**:
- `prepare_progress_chart_data`, `progress_chart_end_date`, `progress_chart_start_date` を private メソッドとして定義する。
- `@book` インスタンス変数が設定されていることを前提とする。

### 2. BooksController / BookMemosController

**責務**:
- `ProgressChartPreparable` を include する。
- 重複する private メソッドを削除する。

## テスト戦略

### ユニットテスト / リクエストテスト
- `spec/requests/books_spec.rb`:
  - 読書ログが存在する状態での `GET /books/:id` リクエストにおいて、インスタンス変数 `@progress_chart_max_pages` が `book.pages` と一致していること、および HTML に正しくその値が含まれていることを検証する。
- `spec/requests/book_memos_spec.rb`:
  - 読書ログが存在する状態でメモ作成（`POST /books/:book_id/book_memos`）がバリデーションエラー（空）になった場合、正常に `422` レスポンスが返り、かつ `@progress_chart_data` に `cumulative_pages` が正しく含まれていることを検証する。

## ディレクトリ構造

```
app/
├── controllers/
│   ├── concerns/
│   │   └── progress_chart_preparable.rb (NEW)
│   ├── books_controller.rb (MODIFY)
│   └── book_memos_controller.rb (MODIFY)
spec/
└── requests/
    ├── books_spec.rb (MODIFY)
    └── book_memos_spec.rb (MODIFY)
```

## 実装の順序

1. `app/controllers/concerns/progress_chart_preparable.rb` の新規作成。
2. `app/controllers/books_controller.rb` の修正（Concern の include と重複メソッド削除）。
3. `app/controllers/book_memos_controller.rb` の修正（Concern の include と重複メソッド削除）。
4. 各リクエストスペック（`books_spec.rb`, `book_memos_spec.rb`）にテストを追加。
5. テスト実行と RuboCop チェック。
