# 設計書

## アーキテクチャ概要

既存の Rails + PostgreSQL 構成に沿って、書籍モデルに `category` カラムを追加し、Railsの `enum` 機能でシステム共通の選択肢を管理します。

## コンポーネント設計

### 1. データベース（マイグレーション）
- `books` テーブルに `category` (integer, default: 0, null: false) を追加します。

### 2. Book モデル (app/models/book.rb)
- `category` の `enum` を定義します。
```ruby
enum :category, {
  other: 0,            # その他
  literature: 1,       # 純文学
  entertainment: 2,    # エンターテインメント
  technical: 3,        # 技術書
  manga: 4,            # 漫画
  essay: 5,            # エッセイ
  practical: 6,        # 実用書
  magazine: 7,         # 雑誌
  academic: 8,         # 専門書
  non_fiction: 9,      # ノンフィクション
  humanities: 10       # 教養
}, default: :other
```
- `category` は `presence: true` バリデーションを追加します（default値があるので実質常に存在します）。

### 3. 多言語化 (config/locales/ja.yml)
- `activerecord.attributes.book.category` に "種類" を定義。
- `book.category` 以下に各キーの日本語翻訳を定義。

### 4. コントローラ (app/controllers/books_controller.rb)
- ストロングパラメータ `book_params` および `edit_book_params` に `:category` を追加。

### 5. ビュー (Views)
- **登録・編集フォーム (`app/views/books/_form.html.erb`)**:
  - 「種類」のセレクトボックスを追加。
- **詳細画面 (`app/views/books/show.html.erb`)**:
  - `<dl class="book-show__details">` に「種類」の行を追加。
- **一覧画面 (`app/views/books/index.html.erb`)**:
  - 書籍カードの「ジャンル」表示の上か横に、「種類」のバッジを表示。

### 6. スタイルシート (`app/assets/stylesheets/books.css`)
- `book-card__category` スタイルを定義。ジャンル (灰色) と差別化するため、水色 (`#e0f2fe`) の背景色とします。

## テスト戦略

### ユニットテスト (spec/models/book_spec.rb)
- `category` の定義テスト（各 enum 値が正しくマップされていること、デフォルトが `other` であること）。

### システムテスト (spec/system/books/books_crud_spec.rb)
- 書籍登録時に「種類」を「技術書」に選択して保存し、詳細画面および一覧画面で「技術書」が正しく表示されること。
- 書籍編集時に「種類」を別の値に変更して保存できること。

## ディレクトリ構造

```
app/
├── assets/
│   └── stylesheets/
│       └── books.css (修正: book-card__category の定義追加)
├── controllers/
│   └── books_controller.rb (修正: ストロングパラメータに category 追加)
├── models/
│   └── book.rb (修正: enum :category 定義追加)
└── views/
    └── books/
        ├── _form.html.erb (修正: category セレクトボックス追加)
        ├── index.html.erb (修正: category バッジ追加)
        └── show.html.erb (修正: category 詳細項目追加)
db/
└── migrate/
    └── [YYYYMMDDHHMMSS]_add_category_to_books.rb (新規: category カラム追加)
config/
└── locales/
    └── ja.yml (修正: 翻訳定義追加)
spec/
├── factories/
│   └── books.rb (修正: デフォルトの category 定義追加)
└── models/
    └── book_spec.rb (修正: category テスト追加)
```

## 実装の順序

1. マイグレーションファイルの作成と適用 (`rails db:migrate`)
2. `Book` モデルへの `enum` 定義とバリデーション、および `ja.yml` ロケールの修正
3. `BooksController` のパラメータ修正
4. ビュー（form, show, index）の修正とCSSの追加
5. テストコード（Model Spec, System Spec）の追加と検証
