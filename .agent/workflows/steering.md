---
description: ステアリングファイル（tasklist.md等）の作成・更新・振り返りを行う
---

# ステアリング管理ワークフロー

## 1. 計画モード (Planning)

- `.steering/[YYYYMMDD]-[タスク名]/` を作成。
- `.github/skills/steering/templates/` から `requirements.md`, `design.md`, `tasklist.md` をコピーして内容を記述。

## 2. 進捗更新 (Tracking)

- タスク着手前: `tasklist.md` の `[ ]` を `[x]` に変更。
- サブタスクの追加: 必要に応じて `tasklist.md` を分割・詳細化。
- 注釈の追加: 実装方針が変更された場合は理由を追記。

## 3. 振り返りモード (Reflection)

- 全タスク完了後、`tasklist.md` の「実装後の振り返り」セクションを埋める。
- 実装完了日、差分、学び、改善案を記述。
