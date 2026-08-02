# 設計書

## アーキテクチャ概要

GitHub Actions の cron スケジュールを契機として、Rails アプリケーション上で定義されている Rake タスクを本番環境（Render等のコンテキスト）で実行します。

```
[GitHub Actions (cron: 毎日 23:00 UTC)]
        │
        ▼
[rake reading_reports:dispatch] (Rails 環境起動)
        │
        ▼ (日付判定)
├─ 土日か？ ──► ReadingReportDispatchJob.perform_now("weekly", ...)
├─ 1日か？  ──► ReadingReportDispatchJob.perform_now("monthly", ...)
└─ 1/1か？  ──► ReadingReportDispatchJob.perform_now("yearly", ...)
```

## コンポーネント設計

### 1. GitHub Actions Workflow (.github/workflows/reading-report-mail.yml)

**責務**:
- 毎日 JST 08:00 (UTC 23:00) にワークフローを起動する。
- `production` 環境のコンテキストで `bundle exec rake reading_reports:dispatch` を実行する。

**実装の要点**:
- cron の設定を `0 23 * * *` とすることで、日本時間の毎日午前 08:00 (協定世界時 23:00) に実行する。
- 実行するタスク名を `reading_reports:weekly` から `reading_reports:dispatch` に変更する。

## テスト戦略

### ユニットテスト
- 今回は GitHub Actions の YAML ファイルの設定変更のみであり、Rake タスク自体のロジック変更はないため、既存の Rspec `spec/tasks/reading_reports_rake_spec.rb` が正常にパスすることを確認する。

## ディレクトリ構造

```
.github/
└── workflows/
    └── reading-report-mail.yml (MODIFY)
```

## 実装の順序

1. `.github/workflows/reading-report-mail.yml` の変更。
2. 既存のテスト `spec/tasks/reading_reports_rake_spec.rb` の実行。
3. RuboCop の実行。
