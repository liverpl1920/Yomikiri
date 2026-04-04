# タスクリスト

## フェーズ1: ブランチ準備

- [x] featureブランチをmainの最新にリベース/マージ
- [x] CI設定ファイルの最終確認

## フェーズ2: PR作成

- [x] PR作成（`feature/issue-42-ci-pipeline` → `main`）→ PR #56

## フェーズ3: CI確認・修正

- [x] CIランの確認（lint-security ジョブ）→ pass
- [x] CIランの確認（RSpec ジョブ）→ pass
- [x] CI失敗があれば修正してプッシュ
  - `Project Automation/Move to In Progress` が失敗
  - 原因: `BODY="${{ github.event.pull_request.body }}"` がPRボディをシェルスクリプトに直接展開→シェルインジェクション
  - 修正: `env: BODY: ${{ ... }}` 経由で渡すよう変更

## フェーズ4: マージ

- [x] CIグリーン確認（全チェック通過）
- [x] PRをsquashマージ（PR #56 → main）
- [x] ローカルmainをpull

## 振り返り（2026-03-11）

- **実装完了日**: 2026-03-11
- **最終PR**: #56（squashマージ）
- **計画と実績の差分**:
  - credentials不一致・db:schema:load・ruby-version-file など想定外の修正が多数発生
  - project-automation.yml のシェルインジェクションバグ（PRボディの直接展開）は見落としやすい落とし穴
- **学んだこと**:
  - GitHub Actions の `run:` ステップで `${{ }}` をシェル変数に直接代入すると特殊文字がシェルインジェクションになる。必ず `env:` 経由で渡すこと
  - feature branch作成後にmainが大きく変わるとコンフリクトが多発するため、こまめにmainをマージすること
