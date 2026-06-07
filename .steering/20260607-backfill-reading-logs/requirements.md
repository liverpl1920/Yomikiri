# 要求内容

## 概要
過去に「過去に読んだ本として登録 (`is_past_reading`)」された書籍データで、読書ログ（`ReadingLog`）が存在しないもの（`completed`状態）に対し、不足している `ReadingLog` レコードを一括作成（補完）するデータ移行処理（Migration および Rakeタスク）を実装します。

## 背景
「過去に読んだ本として登録」された書籍について、新規登録時に読書ログ（`ReadingLog`）が作成されない不具合が存在したため、既にデータベースに登録されている既存データに読書ログが存在しないケースがあります。これにより、ダッシュボードの総読書ページ数等にその書籍のページ数が正しく反映されません。既存の不整合データを解消するために、データ移行処理が必要です。

## 実装対象の機能

### 1. データ移行Rakeタスクの追加
- `lib/tasks/data_migration.rake` に、`data_migration:backfill_reading_logs` タスクを作成します。
- `status: :completed` かつ `reading_logs` レコードが0件の書籍を対象に、その書籍の総ページ数分の `ReadingLog` を作成します。
- 作成する `ReadingLog` の属性：
  - `pages_read`: 書籍の `pages`
  - `read_at`: 書籍の `completed_at` の日付（存在しない場合は `created_at` の日付）
  - `start_page`: 1
  - `end_page`: 書籍の `pages`

### 2. データ移行マイグレーションの追加
- `db/migrate/` に `BackfillReadingLogsForPastCompletedBooks` マイグレーションを作成します。
- マイグレーションの実行時に、上記と同様の移行処理を自動で実行します。
- 将来モデルのバリデーションや構造が変更されてもマイグレーションが壊れないよう、マイグレーションファイル内でローカルな `Book` および `ReadingLog` クラスを定義して移行を実行します。

## 受け入れ条件

### データ移行の正確性
- [ ] 移行処理実行後、`status` が `completed` で `reading_logs` が存在しなかった書籍に対し、対応する `ReadingLog` が1件作成されていること。
- [ ] 作成された `ReadingLog` の `pages_read` が書籍の `pages` と一致していること。
- [ ] 作成された `ReadingLog` の `read_at` が `completed_at.to_date` （または `created_at.to_date`）と一致していること。
- [ ] すでに `reading_logs` が存在する書籍や、`completed` 以外の書籍には `ReadingLog` が新規作成されないこと。

### ダッシュボードの表示
- [ ] データ移行実行後、ダッシュボードの総読了ページ数（`@total_pages_read`）に、補完された書籍のページ数が加算されていること。

## 成功指標
- 既存の不整合データが解消され、ダッシュボードの統計情報が正しく計算されるようになること。

## スコープ外
- `completed` 以外のステータスの書籍に対する読書ログの自動補完。
- 手動で誤って削除された読書ログの復元。

## 参照ドキュメント
- `docs/product-requirements.md` - プロダクト要求定義書
- `docs/functional-design.md` - 機能設計書
- `docs/architecture.md` - アーキテクチャ設計書
