# Issue #9: Book モデルの作成 — 設計

## 実装アプローチ

### マイグレーション

`rails generate migration CreateBooks` ではなく、直接マイグレーションファイルを作成する。
ファイル名: `20260315000000_create_books.rb`

### モデルファイル

`app/models/book.rb` を作成する。

### テスト

`spec/models/book_spec.rb` を作成し、以下を検証する:
- バリデーション（必須項目, 数値範囲）
- enum の動作
- アソシエーション（belongs_to :user）

### 注意事項

- `user.rb` には既に `has_many :books, dependent: :destroy` が記述されているため、変更不要
- `status` の enum は `prefix: true` を使わず、シンプルに定義する
- `target_pages <= total_pages` の検証はカスタムバリデーションで実装する
