# 設計書

## アーキテクチャ概要

本機能はデータ移行処理であり、既存の不整合データを解消するためのものです。
以下の2つの方法で実行できるようにします。
1. **Rakeタスク**: 運用保守や手動実行のためのタスク。
2. **Database Migration**: デプロイ時に自動実行するためのマイグレーション。

```
[Books Table] (status: :completed, no reading_logs)
     │
     ▼
[Data Migration (Rake Task / Migration)]
     │
     ▼ (Find and Backfill)
[ReadingLogs Table] (pages_read: pages, read_at: completed_at || created_at)
```

## コンポーネント設計

### 1. Rakeタスク: `lib/tasks/data_migration.rake`

**責務**:
- コマンドラインから実行可能な `data_migration:backfill_reading_logs` タスクを提供する。
- 実行時に、対象データを取得し、ログを出力しながら安全にデータ移行を行う。

**実装の要点**:
- `Book.completed.includes(:reading_logs).find_each` を用いて、メモリ使用量を抑えながらループ処理する。
- 関連する `reading_logs` が空の書籍のみを対象とする。
- 実行ログを標準出力に出力し、処理件数などを報告する。

### 2. マイグレーション: `db/migrate/[timestamp]_backfill_reading_logs_for_past_completed_books.rb`

**責務**:
- データベースマイグレーションの実行時 (`rails db:migrate`) に、自動的にデータ移行処理を実行する。

**実装の要点**:
- マイグレーションファイル内に、ActiveRecordモデルの変更に備えてローカルクラス `Book` と `ReadingLog` を定義する。
- 実際の移行処理ロジックはRakeタスクと同様に行う。

## テスト戦略

### ユニットテスト
- Rakeタスクのテスト (`spec/lib/tasks/data_migration_spec.rb`)
  - 正常系: `status: :completed` かつ `reading_logs` が存在しない書籍に対して、`ReadingLog` が正しく作成されること。
  - 正常系: `completed_at` が存在する場合はその日付、存在しない場合は `created_at` の日付が `read_at` に設定されること。
  - 境界値・対象外: `status` が `unread` や `reading` の書籍には `ReadingLog` が作成されないこと。
  - 境界値・対象外: `status: :completed` でも既に `reading_logs` が存在する書籍には `ReadingLog` が作成されないこと。
- マイグレーションのテスト
  - マイグレーションファイルを実行して正しくデータが移行されるか、テストスイートまたは手動で適用して検証する。

## ディレクトリ構造

```
lib/
  └── tasks/
        └── data_migration.rake       # [NEW] Rakeタスクの定義
db/
  └── migrate/
        └── 20260607xxxxxx_backfill_reading_logs_for_past_completed_books.rb  # [NEW] マイグレーション
spec/
  └── lib/
        └── tasks/
              └── data_migration_spec.rb  # [NEW] Rakeタスクのテスト
```

## 実装の順序

1. Rakeタスク `lib/tasks/data_migration.rake` の実装
2. Rakeタスクに対するテスト `spec/lib/tasks/data_migration_spec.rb` の作成と検証
3. マイグレーション `db/migrate/20260607xxxxxx_backfill_reading_logs_for_past_completed_books.rb` の作成と検証
4. 全体の動作確認、RuboCopおよびRSpecの実行

## セキュリティ考慮事項
- 特になし（管理者用タスクおよびデプロイ時マイグレーションのため）。

## パフォーマンス考慮事項
- 既存の書籍データが大量にある可能性を考慮し、`find_each` を用いて一括ロードによるメモリ圧迫を避ける。
- `includes(:reading_logs)` を用いて、N+1クエリを防ぐ。
