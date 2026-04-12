# タスクリスト

## 🚨 タスク完全完了の原則

**このファイルの全タスクが完了するまで作業を継続すること**

### 必須ルール
- **全てのタスクを`[x]`にすること**
- 未完了タスク（`[ ]`）を残したまま作業を終了しない

---

## フェーズ1: 設計と実装

- [x] ステアリングファイルの作成
  - [x] requirements.md を作成
  - [x] design.md を作成
  - [x] tasklist.md を作成

- [x] 期限延長システムスペックの修正
  - [x] `spec/system/books/deadline_spec.rb` の date 入力を `fill_in` に変更
  - [x] 成功メッセージ検証の期待値を維持

## フェーズ2: 品質チェックと修正

- [x] テストが通ることを確認
  - [x] `bundle exec rspec spec/system/books/deadline_spec.rb`
- [x] リントエラーがないことを確認
  - [x] `bundle exec rubocop spec/system/books/deadline_spec.rb`

- [x] implementation-validator で品質検証
  - [x] サブエージェント実行結果を確認

## フェーズ3: 振り返り

- [x] 実装後の振り返りを記録

---

## 実装後の振り返り

### 実装完了日

2026-04-12

### 計画と実績の差分

**計画と異なった点**:
- add-feature テンプレートの `npm test/lint/typecheck` は本リポジトリで script 未定義のため実行不能だった
- 代替として Rails プロジェクトの検証コマンド（`bundle exec rspec`, `bundle exec rubocop`）で品質確認を実施した

**新たに必要になったタスク**:
- implementation-validator の提案を反映し、日付文字列を `.strftime('%Y-%m-%d')` に統一した

**技術的理由でスキップしたタスク**（該当する場合のみ）:
- `npm test` / `npm run lint` / `npm run typecheck`
  - スキップ理由: ルートに `package.json` が存在せず npm scripts が定義されていないため
  - 代替実装: `bundle exec rspec spec/system/books/deadline_spec.rb` と `bundle exec rubocop spec/system/books/deadline_spec.rb` を実行

### 学んだこと

**技術的な学び**:
- `type="date"` への `execute_script` 直接代入は headless Chrome で flaky になることがある
- 同じ目的でも `fill_in` を使うとユーザー操作に近く、Capybara の待機機構と整合しやすい

### 次回への改善提案

- date input を扱う system spec では `fill_in` を第一選択にする
- ジェネリックな自動フロー手順（npm系）と Rails 実プロジェクト手順の差分を事前に吸収する
