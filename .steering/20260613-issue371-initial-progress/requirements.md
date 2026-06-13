# 要件定義 (Issue #371)

## 概要
書籍新規登録時、既に読み進めているページ数がある場合（「既に読んだページ数」が 0 より大きい場合）、そのページ数を当日の読書実績としてカウントするため、自動的に当日の読書ログ（`ReadingLog`）を生成する。

## 詳細要件
- **対象となるケース（通常の登録）**
  - 「過去に読んだ本として登録（`is_past_reading`）」にチェックが**ない**。
  - 「既に読んだページ数（`current_page`）」が **0 より大きい**。
  - 書籍が正常に新規登録（作成）されたこと。
- **自動生成する `ReadingLog` の属性**
  - `pages_read`: 登録された `current_page`
  - `read_at`: `Date.current`（今日の日付）
  - `start_page`: `1`
  - `end_page`: 登録された `current_page`
- **対象外となるケース**
  - `is_past_reading` が `true` の場合（既存の `create_reading_log_for_past_reading` コールバックが走り、全ページ分のログが作成されるため、二重生成を防ぐ）。
  - `current_page` が `0` の場合（進捗がないためログは不要）。
