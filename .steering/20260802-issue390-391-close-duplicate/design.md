# 設計書

## 変更内容の概要

すでに `main` ブランチに適用されている実装の設計概要です。

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

### 1. GitHub Actions 変更内容
- スケジュールを毎日 JST 08:00 (UTC 23:00) に設定: `cron: "0 23 * * *"`
- 実行タスクを `reading_reports:weekly` から `reading_reports:dispatch` へ変更。

### 2. Rakeタスクの仕様
- `reading_reports:dispatch` 内で日付を判定し、それぞれ対応するレポート送信ジョブを起動する。

本 PR では追加のソースコード変更はありません。重複 Issue #390, #391 をクローズするための PR として構成します。
