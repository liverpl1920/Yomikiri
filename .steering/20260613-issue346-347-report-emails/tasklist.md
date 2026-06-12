# Tasklist: 月末のまとめメール（月次レポート）および年末のまとめメール（年次レポート）の送信

## 1. 準備・ブランチ作成
- [x] git branch `feature/#346-347-report-emails` の作成・チェックアウト

## 2. ReadingReportSummaryService の拡張
- [x] `PERIOD_TYPES` に `:yearly` を追加
- [x] 期間計算ロジック `period_range` の変更（`monthly` を前月に、`yearly` を前年に設定）
- [x] 既存のテストがパスするように `spec/services/reading_report_summary_service_spec.rb` の `monthly` のテストを基準日「翌月1日」に修正
- [x] 月次レポート用追加データ (`reading_days_count`, `completed_books`, `progressing_books`, `tsundoku_balance`, `deadline_status`, `next_month_urgent_books`, `random_memos`) の集計処理を実装
- [x] 年次レポート用データ (`peak_month`, `lightning_award_book`, `most_faced_book`, `excuse_award_book`, `most_memo_book_and_excerpt`, `tsundoku_current_state`, `new_year_proposal_book`) の集計処理を実装
- [x] `ReadingReportSummaryService` の月次・年次の新機能テストを追加・実行

## 3. ReadingReportMailer の拡張
- [x] `ReadingReportMailer` に `yearly_report` を追加
- [x] 月次レポート用のテキストメールテンプレート `app/views/reading_report_mailer/monthly_report.text.erb` を要件に従い詳細化
- [x] 年次レポート用のテキストメールテンプレート `app/views/reading_report_mailer/yearly_report.text.erb` を要件に従い新規作成
- [x] メーラーのテスト `spec/mailers/reading_report_mailer_spec.rb` を追加・更新

## 4. ジョブとRakeタスクの変更
- [x] `ReadingReportDispatchJob` に `:yearly` をサポートする分岐を追加
- [x] `lib/tasks/reading_reports.rake` の `dispatch` タスクにて、`monthly` の起動条件を「毎月1日」に変更
- [x] `lib/tasks/reading_reports.rake` の `dispatch` タスクにて、`yearly` の起動条件を「毎年1月1日」に変更しジョブを呼び出すように追加
- [x] ジョブのテスト `spec/jobs/reading_report_dispatch_job_spec.rb` を追加・更新
- [x] Rakeタスクのテスト `spec/tasks/reading_reports_rake_spec.rb` を追加・更新

## 5. 動作検証と品質確認
- [x] `bundle exec rspec` を実行し、すべてのテストがパスすることを確認
- [x] `bundle exec rubocop` を実行し、コード規約違反がないことを確認
- [x] 必要に応じて手動でのタスク実行テスト（Rakeタスクの実行と配信確認）
- [x] コミット & プッシュ & プルリクエストの作成
