# Tasklist: ブランチ保護ルール・PRテンプレート・Projects自動化の設定

## 実装タスク

### Phase 1: PR テンプレート更新
- [x] `.github/pull_request_template.md` を Issue #44 の要件に合わせて更新する
  - 概要セクション
  - 関連 Issue（Closes #）
  - 実装内容チェックリスト
  - 動作確認チェックリスト
  - CI確認チェック（RuboCop / RSpec / Brakeman が GREEN）

### Phase 2: Projects 自動化 Workflow 強化
- [x] GitHub Projects v2 の GraphQL ID（Project ID, Status Field ID, Option IDs）を取得する
- [x] `.github/workflows/project-automation.yml` を更新する
  - PR マージ時に linked issue を "Done" へ移動する処理を実装（GraphQL API 使用）
  - 注: プロジェクトに "In Review" ステータスが存在しないため、PR作成時のステータス移動はスキップ

### Phase 3: ブランチ保護ルール設定
- [x] GitHub API を使って `main` ブランチに保護ルールを設定する
  - Required status checks: `RuboCop & Brakeman & bundler-audit`, `RSpec`
  - Require branches to be up to date: true
  - Enforce admins: true
  - Do not allow bypassing: true

---

## 実装完了後の振り返り

（実装完了後に記入）
