# タスクリスト

## 🚨 タスク完全完了の原則

**このファイルの全タスクが完了するまで作業を継続すること**

### 必須ルール
- **全てのタスクを`[x]`にすること**
- 「時間の都合により別タスクとして実施予定」は禁止
- 「実装が複雑すぎるため後回し」は禁止
- 未完了タスク（`[ ]`）を残したまま作業を終了しない

---

## フェーズ1: 集計・メール送信機能の実装

- [x] 集計サービスを実装する
	- [x] `ReadingReportSummaryService` を追加し期間別集計を実装
	- [x] `spec/services/reading_report_summary_service_spec.rb` を追加

- [x] メーラーを実装する
	- [x] `ReadingReportMailer` と週次/月次テンプレートを追加
	- [x] `spec/mailers/reading_report_mailer_spec.rb` を追加

## フェーズ2: 定期配信ジョブと起動経路

- [x] 配信ジョブを実装する
	- [x] `ReadingReportDispatchJob` を追加（再試行・エラーログ含む）
	- [x] `spec/jobs/reading_report_dispatch_job_spec.rb` を追加

- [x] 実行トリガーを実装する
	- [x] `lib/tasks/reading_reports.rake` を追加し週末/月末判定を実装
	- [x] `.github/workflows/reading-report-mail.yml` を追加
	- [x] `spec/tasks/reading_reports_rake_spec.rb` を追加

## フェーズ3: 品質チェックと修正

- [x] テストを実行して通過させる
	- [x] `bundle exec rspec`
- [x] リントを実行して通過させる
	- [x] `bundle exec rubocop`
- [x] （互換チェック）Node テスト系コマンドを確認する
	- [x] ~~`npm test`~~（理由: Rails + Importmap 構成で package.json の test script が定義されていない）
	- [x] ~~`npm run lint`~~（理由: Rails + Importmap 構成で package.json の lint script が定義されていない）
	- [x] ~~`npm run typecheck`~~（理由: Rails + Importmap 構成で package.json の typecheck script が定義されていない）

## フェーズ4: ドキュメント更新

- [x] 必要に応じて永続ドキュメントを更新（今回変更は機能追加のみで既存設計の前提を崩さないため更新不要）
- [x] 実装後の振り返りを記載

---

## 実装後の振り返り

### 実装完了日
2026-05-17

### 計画と実績の差分

**計画と異なった点**:
- GitHub Actions の定期実行は週次/月次それぞれの cron 分離ではなく、日次実行 + task 側判定に変更した。
- メール送信失敗の再試行は ActiveJob バックエンド依存を避けるため、ジョブ内のユーザー単位 retry で実装した。

**新たに必要になったタスク**:
- `spec/tasks/reading_reports_rake_spec.rb` で Rake タスクロード方法の調整が必要になり、`Rails.application.load_tasks` ベースへ修正した。

**技術的理由でスキップしたタスク**（該当する場合のみ）:
- `npm test`
	- スキップ理由: 本リポジトリは Node スクリプト管理をしておらず、script 未定義で実行不可。
	- 代替実装: `bundle exec rspec` を全件実行し回帰を確認。
- `npm run lint`
	- スキップ理由: lint script 未定義で実行不可。
	- 代替実装: `bundle exec rubocop` を全件実行。
- `npm run typecheck`
	- スキップ理由: typecheck script 未定義で実行不可。
	- 代替実装: Ruby コードの静的チェックは RuboCop、動作保証は RSpec で担保。

### 学んだこと

**技術的な学び**:
- 定期配信は cron を細分化するより、日次実行 + アプリ側条件判定のほうが運用とテストを単純化できる。
- メール送信の失敗耐性はジョブ単位ではなくユーザー単位で retry すると部分失敗に強い。

**プロセス上の改善点**:
- tasklist をフェーズ単位で即時更新することで、未完了タスクの取りこぼしを防げた。

### 次回への改善提案
- 月次レポートの件名・本文に達成率指標（目標ページとの差分）を追加すると振り返り価値が上がる。
- 必要に応じて配信対象を「当月アクティブユーザーのみ」に絞る最適化を検討する。
