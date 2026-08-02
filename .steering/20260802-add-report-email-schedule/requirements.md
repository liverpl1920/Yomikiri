# 要求内容

## 概要

GitHub Actionsワークフローを変更し、毎日自動的に `reading_reports:dispatch` タスクを実行するスケジュールを追加します。これにより、すでに実装済みの週次、月次、および年次レポートの自動送信を適切なタイミングで稼働させます。

## 背景

現在、`.github/workflows/reading-report-mail.yml` は毎週土曜日に `reading_reports:weekly` を実行するのみであり、月次および年次のレポートが自動的に配信されるスケジュールが存在しません。
Rakeタスクには日付を判定して適切なレポート配信ジョブを実行する `reading_reports:dispatch` が既に存在しているため、GitHub Actionsのcronトリガーを毎日実行に変更し、この `dispatch` タスクを呼び出すように変更することで、すべての配信スケジュールを自動化できます。

## 実装対象の機能

### 1. GitHub Actions ワークフローのスケジュール変更
- `reading-report-mail` ワークフローの cron トリガーを毎週土曜日から毎日に変更する。
- 実行する Rake タスクを `reading_reports:weekly` から `reading_reports:dispatch` に変更する。

## 受け入れ条件

### 定期実行スケジュール
- [ ] ワークフローのスケジュールが毎日 JST 08:00（UTC 23:00）に設定されていること。
- [ ] 実行する Rake タスクが `reading_reports:dispatch` に変更されていること。

## 成功指標

- GitHub Actions の設定が正しく変更され、Rake タスクが `reading_reports:dispatch` を向くこと。

## スコープ外

以下はこのフェーズでは実装しません:
- Rake タスク `reading_reports:dispatch` のロジック自体の変更。

## 参照ドキュメント

- `docs/architecture.md` - アーキテクチャ設計書
- `docs/development-guidelines.md` - 開発ガイドライン
