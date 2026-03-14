# Design: ブランチ保護ルール・PRテンプレート・Projects自動化の設定

## 実装アプローチ

### 1. ブランチ保護ルール
GitHub REST API（または CLI）を使用して `main` ブランチの保護ルールを設定する。

```bash
gh api repos/{owner}/{repo}/branches/main/protection \
  --method PUT \
  --input - << 'EOF'
{
  "required_status_checks": {
    "strict": true,
    "contexts": [
      "RuboCop & Brakeman & bundler-audit",
      "RSpec"
    ]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "required_approving_review_count": 0,
    "dismiss_stale_reviews": false
  },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}
EOF
```

### 2. PR テンプレート
既存の `.github/pull_request_template.md` を Issue #44 の要件に合わせて更新する。

構成:
- 概要セクション
- 関連 Issue（Closes #）
- 実装内容チェックリスト（実装した内容を列挙）
- 動作確認チェックリスト（手動での動作確認項目）
- CI確認チェック（RuboCop / RSpec / Brakeman が GREEN）

### 3. Projects 自動化 Workflow
GitHub Projects v2 の GraphQL API を用いて、Issue/PR の Status フィールドを更新する。

#### 必要な情報（GraphQL で取得）
- Project Node ID: `PVT_...`
- Status Field ID: `PVTF_...`
- "In Review" Option ID: `...`
- "Done" Option ID: `...`

#### ワークフロー構成
トリガー:
- `pull_request: [opened]` → linked issue を In Review に移動
- `pull_request: [closed]` + merged → linked issue/PR を Done に移動

#### 実装方針
GraphQL API を使った `actions/github-script` により Issue & PR のステータスを更新する。

### 4. GitHub Secrets
`PROJECT_TOKEN` は既に登録済みの前提だが、不足している場合は手動で登録が必要。
（GitHub Secrets への書き込みはワークフローから行えないため、CI 実行テスト後の確認で対応）

## 変更ファイル
1. `.github/pull_request_template.md` — PR テンプレートの更新
2. `.github/workflows/project-automation.yml` — Projects 自動化ワークフローの強化
3. ブランチ保護ルール — GitHub API 経由で設定（ファイル変更なし）
