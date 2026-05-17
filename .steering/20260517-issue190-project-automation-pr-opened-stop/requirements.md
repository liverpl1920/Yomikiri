# 要求内容: Project AutomationのPR作成時実行停止

## 概要

Issue #190 に対応し、Project Automation ワークフローが PR 作成時に実行されないようにトリガーを見直す。
PR マージ時の linked issue を Done へ移動する挙動と、Issue 作成/再オープン時の自動追加は維持する。

## 背景

現在の `.github/workflows/project-automation.yml` は `pull_request` の `opened` をトリガーに含んでいるため、PR 作成直後に不要なジョブが走り Actions 一覧のノイズになっている。

## 実装対象の機能

### 1. Workflowトリガーの最小化
- `project-automation.yml` の `pull_request.types` から `opened` を除外する。
- PR マージ時に必要な `closed` イベントによる処理は維持する。
- Issue の `opened/reopened` による自動追加は維持する。

### 2. 運用ドキュメント更新
- 変更後に Project Automation がいつ実行されるかを README または運用メモへ明記する。

## 受け入れ条件

### Workflowトリガー
- [ ] PR 作成時に Project Automation が起動しない。
- [ ] PR マージ時に linked issue を Done に移動する条件が維持される。
- [ ] Issue 作成/再オープン時の自動追加が維持される。

### ドキュメント
- [ ] 実行タイミング変更が README または運用ドキュメントに明記されている。

## 成功指標

- Actions 一覧で PR 作成時の Project Automation 実行が発生しない。
- 既存の PR マージ時/Issue 作成時の運用が回帰しない。

## スコープ外

以下はこのフェーズでは実装しない:

- Project board のステータス値やフィールドIDの見直し
- CI 全体構成の刷新
- 他 workflow のトリガー最適化

## 参照ドキュメント

- `docs/development-workflow.md` - 運用フロー
- `docs/development-guidelines.md` - 開発ガイドライン
- `issue/ISSUE.md` - Issue 一覧
