# タスクリスト

## 🚨 タスク完全完了の原則

このファイルの全タスクが完了するまで作業を継続すること。

---

## フェーズ1: 要因特定と修正

- [x] ISSUE134の再現確認
	- [x] Issue記載の再現コマンドで失敗を確認
	- [x] 失敗箇所が`config/environments/production.rb`であることを確認

- [x] production.rb の修正
	- [x] logger初期化前でも安全な警告出力へ変更
	- [x] `SENDGRID_API_KEY`未設定時に起動継続することを確認

## フェーズ2: 検証

- [x] ISSUE再現コマンドで成功確認
	- [x] `unset RAILS_MASTER_KEY && SECRET_KEY_BASE_DUMMY=1 RAILS_ENV=production bundle exec rails assets:precompile`

- [x] プロジェクト標準の品質チェック
	- [x] `bundle exec rspec`
	- [x] `bundle exec rubocop`

## フェーズ3: プロンプト要求の追加検証

- [x] add-feature.prompt.md 指定コマンドの実行結果を確認
	- [x] ~~`npm test`~~（理由: Railsアプリ構成で`package.json`に`test` scriptが存在しないため実行不可）
	- [x] ~~`npm run lint`~~（理由: Railsアプリ構成で`package.json`に`lint` scriptが存在しないため実行不可）
	- [x] ~~`npm run typecheck`~~（理由: Railsアプリ構成で`package.json`に`typecheck` scriptが存在しないため実行不可）

## フェーズ4: 仕上げ

- [x] 実装内容の品質検証（implementation-validator）
- [ ] コミット
- [ ] push & PR作成
- [ ] CI監視 (`gh pr checks --watch`)
- [ ] 実装後の振り返りを記載

---

## 実装後の振り返り

### 実装完了日
{YYYY-MM-DD}

### 計画と実績の差分

**計画と異なった点**:
- {差分を記載}

**新たに必要になったタスク**:
- {必要に応じて記載}

**技術的理由でスキップしたタスク**（該当する場合のみ）:
- {タスク名}
	- スキップ理由: {具体的な技術的理由}
	- 代替実装: {何に置き換わったか}

### 学んだこと

**技術的な学び**:
- {学びを記載}

**プロセス上の改善点**:
- {改善点を記載}

### 次回への改善提案
- {改善提案を記載}
