# タスクリスト

## 🚨 タスク完全完了の原則

**このファイルの全タスクが完了するまで作業を継続すること**

### 必須ルール
- **全てのタスクを`[x]`にすること**
- 未完了タスク（`[ ]`）を残したまま作業を終了しない

---

## フェーズ1: ステアリングと要件整理

- [x] ステアリングファイルを作成する
  - [x] `.steering/20260426-issue112-active-storage-deploy-safeguard/requirements.md` を作成
  - [x] `.steering/20260426-issue112-active-storage-deploy-safeguard/design.md` を作成
  - [x] `.steering/20260426-issue112-active-storage-deploy-safeguard/tasklist.md` を作成

- [x] Issue #112 の要件を確認する
  - [x] `gh issue view 112` で仕様を確認
  - [x] 既存の関連設定（`render.yaml`, `production.rb`, `storage.yml`）を確認

## フェーズ2: ドキュメント実装

- [x] 開発フロー文書に Active Storage 本番反映チェックを追加する
  - [x] `docs/development-workflow.md` に AWS 環境変数事前設定手順を追記
  - [x] `feature/#25` と `feature/#26` の推奨マージ順序を追記

- [x] README に運用注意点を追記する
  - [x] `sync: false` の意味（Render ダッシュボード手動設定）を明記
  - [x] `:local` ストレージのリスクと回避策を明記

## フェーズ3: 品質チェックと修正

- [x] 実装変更を implementation-validator で検証する
- [x] RSpec が通ることを確認する
  - [x] `bundle exec rspec`
- [x] RuboCop が通ることを確認する
  - [x] `bundle exec rubocop`
- [x] ~~npm test 実行結果を確認する~~（実装方針変更により不要: 本リポジトリは Rails + importmap 構成で `package.json` が存在せず npm scripts を定義していないため）
  - [x] ~~`npm test`~~（理由: `package.json` 不在で `Missing script: test`）
- [x] ~~npm lint 実行結果を確認する~~（実装方針変更により不要: 本リポジトリは Rails + importmap 構成で `package.json` が存在せず npm scripts を定義していないため）
  - [x] ~~`npm run lint`~~（理由: `package.json` 不在で `Missing script: lint`）
- [x] ~~npm typecheck 実行結果を確認する~~（実装方針変更により不要: 本リポジトリは Rails + importmap 構成で `package.json` が存在せず npm scripts を定義していないため）
  - [x] ~~`npm run typecheck`~~（理由: `package.json` 不在で `Missing script: typecheck`）

## フェーズ4: 仕上げ

- [x] tasklist の振り返りを記入する
- [ ] 変更をコミットする（Issue番号付き）
- [ ] ブランチを push して PR を作成する
- [ ] `gh pr checks --watch` で CI 完了を確認する

---

## 実装後の振り返り

### 実装完了日
2026-04-26

### 計画と実績の差分

**計画と異なった点**:
- npm 系コマンド検証を計画していたが、実リポジトリが Rails + importmap 構成で `package.json` 非採用のため、技術的理由を明記してスキップした。
- implementation-validator の指摘に基づき、README の AWS 環境変数を「常時必須」から「Active Storage 有効化時のみ必須」に修正した。

**新たに必要になったタスク**:
- `docs/development-workflow.md` に PR レビュー時チェックリスト（AWS 4変数・`/up`確認・マージ順序）を追加した。

**技術的理由でスキップしたタスク**（該当する場合のみ）:
- `npm test`
  - スキップ理由: `package.json` が存在せず npm scripts が定義されていない。
  - 代替実装: Rails 標準の検証として `bundle exec rspec` を実行。
- `npm run lint`
  - スキップ理由: `package.json` が存在せず npm scripts が定義されていない。
  - 代替実装: Rails 標準の検証として `bundle exec rubocop` を実行。
- `npm run typecheck`
  - スキップ理由: TypeScript ビルド基盤が存在しない（importmap 構成）。
  - 代替実装: なし（適用外）。

### 学んだこと

**技術的な学び**:
- `sync: false` は IaC 側で値を持たないことを示すため、運用ドキュメントで設定責任を明確化しないと本番停止リスクになる。
- Active Storage 反映は「設定確認」と「マージ順序」の2軸で管理することで事故率を下げられる。

**プロセス上の改善点**:
- validator の指摘を反映して、条件付き要件（Active Storage 有効時のみ）を明文化することでドキュメントの誤読を防げた。
- tasklist に実行結果とスキップ理由を即時記録することで、第三者検証が容易になった。

### 次回への改善提案
- Active Storage 有効化のマージ時は PR テンプレに専用チェック項目を追加し、レビュー漏れをさらに減らす。
- 将来的には CI で「本番設定不足時の警告」を検知できる仕組み（ドキュメントチェック/運用ガード）を検討する。
