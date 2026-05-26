# 要求内容

## 概要

Issue #246「統計画面：読了ボタン経由で完了した本のページ数が統計に反映されない」を修正する。
具体的には、書籍詳細画面の読了ボタンで完了した際に、未記録ページ分をReadingLogへ記録する。

## 背景

現在の `BooksController#complete` は `current_page` を `target_pages` に更新して完了状態にするが、`reading_logs` を作成していない。
統計画面は `reading_logs` のみを集計するため、読了ボタン経由で進んだページが読了ページ数や日別・書籍別集計に反映されない。

## 実装対象の機能

### 1. 読了時の差分ReadingLog記録
- `complete` 実行時に `target_pages - current_page` の差分を計算する。
- 差分が正の場合のみ、`read_at/start_page/end_page/pages_read` を持つReadingLogを1件作成する。

### 2. 既存読了処理の挙動維持
- `status: completed`、`current_page: target_pages`、`completed_at` 設定の既存挙動を維持する。
- 差分が0の場合はReadingLogを作成しない。

## 受け入れ条件

### 読了時の差分ReadingLog記録
- [ ] 読了前 `current_page < target_pages` の本を読了するとReadingLogが1件作成される
- [ ] 作成されるReadingLogの `pages_read` は `target_pages - current_page` と一致する
- [ ] 作成されるReadingLogの `start_page` / `end_page` が差分範囲と一致する

### 既存読了処理の挙動維持
- [ ] 読了後に `status` が `completed` になる
- [ ] 読了後に `current_page` が `target_pages` に揃う
- [ ] `current_page == target_pages` の本を読了してもReadingLogは増えない

## 成功指標

- 読了ボタン操作による未記録ページが統計集計対象になること
- 既存の `update_progress` 由来のReadingLog記録ロジックと整合したデータが保存されること

## スコープ外

以下はこのフェーズでは実装しない:

- 統計集計サービス自体のロジック変更
- UI表示文言や画面レイアウトの変更
- 過去データの補正バッチ

## 参照ドキュメント

- `docs/product-requirements.md` - プロダクト要求定義書
- `docs/functional-design.md` - 機能設計書
- `docs/architecture.md` - アーキテクチャ設計書

