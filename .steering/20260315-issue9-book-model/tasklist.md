# Issue #9: Book モデルの作成 — タスクリスト

## フェーズ1: ブランチ作成

- [x] feature ブランチを作成する（`feature/9-book-model`）

## フェーズ2: マイグレーション

- [x] books テーブルのマイグレーションファイルを作成する
- [x] マイグレーションを実行する（`rails db:migrate`）

## フェーズ3: Book モデル実装

- [x] `app/models/book.rb` を作成する（バリデーション・アソシエーション・enum を定義）
- [x] User モデルの `has_many :books` が定義済みであることを確認する

## フェーズ4: テスト作成

- [x] `spec/models/book_spec.rb` を作成する

## フェーズ5: 品質確認

- [x] RuboCop を実行してコードスタイルを確認する（4 files inspected, no offenses detected）
- [x] RSpec を実行してテストがパスすることを確認する（24 examples, 0 failures）

## 申し送り事項

### 実装完了日
2026年3月15日

### 計画と実績の差分

**計画通りに実装:**
- books テーブルのマイグレーション作成・実行
- Book モデル（バリデーション・アソシエーション・enum）
- spec/models/book_spec.rb（24 examples, 0 failures）

**特記事項:**
- User モデルには既に `has_many :books, dependent: :destroy` が実装済みだった（Issue #4 相当の作業が先行して完了していた）
- `target_pages <= total_pages`・`current_page <= target_pages` はカスタムバリデーションで実装

### 学んだこと
- blank? チェックをカスタムバリデーション内で行うことで、他のバリデーション（numericality）のエラーと重複しない実装ができる

### 次回への改善提案
- Issue #10（積読登録機能）では、`target_pages` の初期値を `total_pages` と同じ値に JS で自動入力する処理が必要
- 書影は Active Storage で管理（Issue #22）のため、今回のマイグレーションにカラムは含まない

