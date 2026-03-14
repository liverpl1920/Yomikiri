# Requirements: ブランチ保護ルール・PRテンプレート・Projects自動化の設定

## 対応 Issue
GitHub Issue #44: ブランチ保護ルール・PR テンプレート・Projects 自動化の設定

## 作業概要
CI/CD の品質ゲートを整備し、PR 駆動開発フローを確立する。

## 要求内容

### 1. ブランチ保護ルール（Branch Protection Rules）
- `main` ブランチに対して以下を有効化:
  - PR 必須（Required pull request reviews）
  - CI ステータスチェック必須（Required status checks）
    - 対象: `RuboCop & Brakeman & bundler-audit`, `RSpec`
  - Require branches to be up to date を有効化
  - Do not allow bypassing the above settings を有効化

### 2. PR テンプレート（.github/pull_request_template.md）
- 以下のセクションを含む:
  - 概要（どのような変更か簡潔に説明）
  - 対応 Issue（`Closes #`）
  - 実装内容チェックリスト
  - 動作確認チェックリスト
  - CI確認チェック（「CI（RuboCop / RSpec / Brakeman）がすべて GREEN であることを確認した」）

### 3. Projects 自動化 Workflow（.github/workflows/project-automation.yml）
- PR 作成時に関連 Issue の Projects カードを "In Review" へ自動移動
- PR マージ時に `Closes #` による Issue 自動クローズ → "Done" へ移動

### 4. GitHub Secrets
- `PROJECT_TOKEN`（Projects 書き込み権限付き PAT）が登録済みであることを確認

## 完了条件
- [ ] CI が全 GREEN でないと main へマージできない
- [ ] PR 作成時にテンプレートが自動適用される
- [ ] PR マージ → "Done" が自動で動作する（※プロジェクトに "In Review" ステータスが存在しないため、PR作成時のステータス移動はスキップ）
