# 設計書

## アーキテクチャ概要

Rails の標準構成に沿って Service + Job + Mailer + Rake task を組み合わせる。
集計ロジックをサービスに閉じ込め、送信の再試行とログは ActiveJob で担保する。

```text
GitHub Actions(cron) / 手動 rake task
	-> ReadingReportDispatchJob
		-> ReadingReportSummaryService
		-> ReadingReportMailer
			-> ActionMailer(SMTP/SendGrid)
```

## コンポーネント設計

### 1. ReadingReportSummaryService

**責務**:
- 指定ユーザー・指定期間の reading_logs を集計する
- 本一覧（タイトル単位）と合計ページ数を返す

**実装の要点**:
- `ReadingLog.joins(:book)` で user_id と日付範囲を絞り込む
- 期間ラベル（週次・月次）や開始日/終了日を統一フォーマットで返す

### 2. ReadingReportMailer

**責務**:
- 週次・月次レポートのメール本文を生成して送信する
- 集計結果をユーザー向け文面へ整形する

**実装の要点**:
- テキストメール（`.text.erb`）を採用して初期実装を簡潔に保つ
- 本一覧が空の場合も「該当なし」を明示して送信する

### 3. ReadingReportDispatchJob

**責務**:
- 対象期間の各ユーザーへメール送信を実行する
- 失敗時再試行と失敗ログ出力を担う

**実装の要点**:
- `retry_on` で送信失敗時の再試行方針を定義
- 期間タイプ（weekly/monthly）に応じた日付範囲を算出

### 4. Rake task + GitHub Actions

**責務**:
- 定期実行トリガーを提供する
- 週末・月末判定を行い適切なジョブを enqueue する

**実装の要点**:
- ワークフローは毎日1回実行し、タスク側で週末/月末判定する
- 手動実行でも同じタスクを呼べる構成にする

## データフロー

### 週次/月次レポート配信
```text
1. cron または手動実行で rake task を起動
2. task が今日の日付を見て weekly/monthly の実行可否を判定
3. ReadingReportDispatchJob がユーザーごとに集計し mailer を呼ぶ
4. mailer が本一覧と合計ページ数を含むメールを送信
5. 成功/失敗をログに記録（失敗は再試行）
```

## エラーハンドリング戦略

### エラーハンドリングパターン

- 送信時の例外は `ReadingReportDispatchJob` で `retry_on StandardError` により再試行
- 再試行上限後は `rescue_from` でエラーログを出力
- ユーザー単位処理のため、1ユーザー失敗時も他ユーザーの送信は継続

## テスト戦略

### ユニットテスト
- `ReadingReportSummaryService` の期間集計（本一覧、合計ページ）
- `ReadingReportDispatchJob` の期間判定・再試行設定

### 統合テスト
- `ReadingReportMailer` の本文に必要情報が含まれること
- `rake reading_reports:dispatch` 実行時のジョブ起動条件（週末/月末）

## 依存ライブラリ

新規ライブラリ追加なし。

## ディレクトリ構造

```text
app/jobs/reading_report_dispatch_job.rb
app/mailers/reading_report_mailer.rb
app/services/reading_report_summary_service.rb
app/views/reading_report_mailer/weekly_report.text.erb
app/views/reading_report_mailer/monthly_report.text.erb
lib/tasks/reading_reports.rake
.github/workflows/reading-report-mail.yml
spec/jobs/reading_report_dispatch_job_spec.rb
spec/mailers/reading_report_mailer_spec.rb
spec/services/reading_report_summary_service_spec.rb
spec/tasks/reading_reports_rake_spec.rb
```

## 実装の順序

1. 集計サービスとメーラーを実装しテスト作成
2. 配信ジョブと rake task を実装しテスト作成
3. GitHub Actions の定期実行設定を追加
4. RSpec と RuboCop で品質確認

## セキュリティ考慮事項

- 送信先は `User` の登録メールアドレスのみを利用する
- メール本文には個人情報を含めず、読書実績の最小限情報だけを記載する

## パフォーマンス考慮事項

- ユーザー単位集計は期間絞り込み + SQL group を利用して不要な全件読み込みを避ける
- `find_each` を使い、大量ユーザー時のメモリ使用量を抑える

## 将来の拡張性

- 期間タイプに日次や四半期を追加できるよう、期間計算をメソッド分離する
- 将来は Sidekiq などのジョブ基盤移行時も Job/Mailer 境界を維持して差し替え可能
