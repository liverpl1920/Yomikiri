# 設計書

## アーキテクチャ概要

本機能はRailsの標準的なMVCアーキテクチャに則って実装します。
一覧画面の既存の検索フォームから `GET /books` リクエストを送り、コントローラーおよびモデルで絞り込み処理を適用して結果をレンダリングします。

```
[Browser (View)]
  │
  │ GET /books?category=literature... (HTTP Request)
  ▼
[BooksController (Controller)]
  │
  │─ 1. normalized_index_search_params で :category パラメータを安全に抽出
  │─ 2. book_search_keys に :category を含めて検索フラグをチェック
  │─ 3. current_user.books.filtered_for_index(params) を呼び出し
  ▼
[Book (Model)]
  │
  │─ 1. filtered_for_index 内で params[:category] が存在する場合に
  │     where(category: params[:category]) のスコープをチェインして絞り込み
  ▼
[Database (PostgreSQL)]
```

## コンポーネント設計

### 1. Book モデル (`app/models/book.rb`)

**責務**:
- Enum (`category`) の定義に対する日本語の多言語対応マップをクラスメソッド `self.categories_i18n` として提供する。
- 検索用のクエリビルダ `filtered_for_index` にて、`category` による絞り込みクエリを追加する。

**実装の要点**:
- `self.categories_i18n` は `categories.keys` からハッシュを作成し、`I18n.t("book.category.#{key}")` を値として返します。
- `filtered_for_index` に `relation = relation.where(category: params[:category]) if params[:category].present?` を追加します。

### 2. BooksController コントローラー (`app/controllers/books_controller.rb`)

**責務**:
- 検索フォームから送信された `:category` パラメータを抽出し、検索パラメータハッシュに含める。
- カテゴリ単独での検索でも絞り込みを実行できるようにする。

**実装の要点**:
- `normalized_index_search_params` で `:category` をストロングパラメータとして扱い、かつハッシュ値に含めます。
- `book_search_keys` 配列に `:category` を追加して、種類単独での検索実行時に `book_search_active` が `true` になるように制御します。

### 3. index ビュー (`app/views/books/index.html.erb`)

**責務**:
- 検索フォーム内に「書籍の種類」を絞り込むためのセレクトボックスを表示する。
- 検索実行後に選択状態を維持する。

**実装の要点**:
- `select_tag` を用い、`options_for_select(Book.categories_i18n.map { |k, v| [v, k] }, @search_params[:category])` によってオプションを構築します。
- `include_blank: "すべての種類"` を指定して、絞り込みを行わない場合のデフォルト選択肢を提供します。
- スタイルクラスには `books-index__search-input` を付与し、既存のテキスト入力欄と見た目を統一します。

## データフロー

### 書籍の種類による絞り込み検索
```
1. ユーザーが「積読一覧」画面で検索フォームを開く。
2. 「書籍の種類」セレクトボックスから特定の種類（例: 「技術書」）を選択し、「検索」ボタンを押下する。
3. ブラウザが GET /books?category=technical をリクエストする。
4. BooksController#index がリクエストを受け、@search_params[:category] に "technical" を設定する。
5. Book.filtered_for_index が呼び出され、category: :technical の本のみをデータベースから取得する。
6. コントローラーが該当する書籍一覧を @books に格納し、index ビューをレンダリングする。
7. ビューが絞り込まれた書籍カードと、選択された状態が維持された「書籍の種類（技術書）」セレクトボックスを表示する。
```

## テスト戦略

### 統合テスト (Request Specs)
`spec/requests/books_index_spec.rb` に以下のテストケースを追加します。
- `category` が異なる本を作成し、特定の `category` でリクエストを送信した際に、合致する本のみが返されること。
- `category` が指定されていないリクエストでは、すべての本が返されること。
- `category` パラメータを送信した際に、レスポンスHTML内のセレクトボックスで該当の `category` が選択状態（`selected="selected"`）になっていること。

## ディレクトリ構造

```
app/
├── controllers/
│   └── books_controller.rb       # パラメータ抽出と検索条件判定の修正
├── models/
│   └── book.rb                   # categories_i18n メソッド定義とクエリ絞り込みの修正
└── views/
    └── books/
        └── index.html.erb        # 検索フォーム内にセレクトボックスを追加
spec/
└── requests/
    └── books_index_spec.rb       # 種類絞り込み機能のテストケース追加
```

## 実装の順序

1. `Book` モデルに `categories_i18n` クラスメソッドを追加し、`filtered_for_index` に絞り込みロジックを追加する。
2. `BooksController` で `category` パラメータを安全に受け取れるよう修正する。
3. `index.html.erb` ビューの検索フォーム内に「書籍の種類」セレクトボックスを実装する。
4. RSpecで実装内容を保証するテストを追加し、実行する。
