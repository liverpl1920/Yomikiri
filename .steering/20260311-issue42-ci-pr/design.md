# 設計

## 現状把握

`feature/issue-42-ci-pipeline` ブランチには以下が既に実装済み:
- `.github/workflows/ci.yml` - RuboCop/Brakeman/bundler-audit/RSpec の4ジョブ
- `.github/workflows/project-automation.yml` - Issue/PRのProjects自動管理
- `config/database.yml` - 重複productionキーを修正済み
- `spec/spec_helper.rb` - minimum_coverage削除済み
- `config/credentials.yml.enc` - ローテーション後の最新版

## 実装アプローチ

### ステップ1: ブランチ最新化
mainの変更（Dependabot PRマージ分）をfeatureブランチに取り込む

### ステップ2: PR作成
```bash
gh pr create \
  --title "#42 CIパイプラインの設計・構築（RuboCop/Brakeman/bundler-audit/RSpec）" \
  --body "Closes #42" \
  --base main \
  --head feature/issue-42-ci-pipeline
```

### ステップ3: CI確認・修正
CIが失敗した場合はログを確認して修正

### ステップ4: マージ
CIグリーン確認後にマージ
