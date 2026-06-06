# Issue #255 要件定義

## 概要
毎週土曜日の8:00（JST）に、その週に読んだ本と取得したメモをまとめたメールを自動送信する。

## 背景
- 1週間の読書活動を定期的に振り返れる仕組みがあると継続しやすい
- 書籍の読了/読書進捗だけでなく、メモも含めて振り返りたい

## 要件
- 毎週土曜日8:00にメール送信処理を実行する
- 対象期間は「その週（週次）」= 直近7日間（土曜を基準日として reference_date - 6.days〜reference_date）
- メール本文に以下を含める
  - その週に読んだ本の情報（既存）
  - その週に記録したメモの情報（新規追加）
- メール送信失敗時のログ/再試行：既存の `deliver_with_retry` で対応済み

## 完了条件
- 毎週土曜8:00 JST（= 金曜 23:00 UTC）の GitHub Actions cron で週次サマリーメールが送信される
- メール内容に週次の読書情報とメモ情報が表示される
- 既存のメール配信・読書記録機能に回帰不具合がない

## 補足
- タイムゾーン: JST (Asia/Tokyo)。GitHub Actions の cron は UTC 基準なので `0 23 * * 5`（金曜23:00 UTC = 土曜08:00 JST）
- 週の定義: 土曜日を基準日とし、その7日前（日〜土）を対象期間とする
- メモは `BookMemo` モデル（`book_memos` テーブル）が対象。`created_at` で期間フィルタリング

## 既存実装との関係
- `ReadingReportSummaryService`: 既存。メモ情報の集計（`memo_details`）を追加する
- `ReadingReportMailer#weekly_report`: 既存。そのまま利用
- `weekly_report.text.erb`: 既存。メモセクションを追加する
- `reading-report-mail.yml`: 既存。cron を土曜8時JST に変更する
- `reading_reports.rake`: 既存。変更不要（`weekly` タスクはそのまま）
