# タスクリスト

## 🚨 タスク完全完了の原則

**このファイルの全タスクが完了するまで作業を継続すること**

### 必須ルール
- **全てのタスクを`[x]`にすること**
- 「時間の都合により別タスクとして実施予定」は禁止
- 「実装が複雑すぎるため後回し」は禁止
- 未完了タスク（`[ ]`）を残したまま作業を終了しない

---

## フェーズ1: render.yaml 修正（Neon対応）

- [x] render.yaml の `DATABASE_URL` 設定を `fromDatabase` から `sync: false` に変更する
  - [x] `fromDatabase: name: yomikiri-db` を削除する
  - [x] `sync: false` に変更してダッシュボードでの手動設定に対応

## フェーズ2: 本番環境設定の確認・修正

- [x] `config/database.yml` の production 設定を確認する
  - [x] `url: <%= ENV["DATABASE_URL"] %>` が設定されていることを確認
- [x] `config/puma.rb` の PORT 設定を確認する
  - [x] `ENV.fetch("PORT", 3000)` が設定されていることを確認
- [x] `config/environments/production.rb` の設定を確認する
  - [x] `config.force_ssl = true` が設定されていることを確認
  - [x] `RAILS_LOG_TO_STDOUT` 対応のロガー設定があることを確認

## フェーズ3: README.md へのデプロイ手順追記

- [x] README.md にデプロイ手順セクションを追加する
  - [x] 必要な環境変数リスト（DATABASE_URL, RAILS_MASTER_KEY）
  - [x] Render + Neon セットアップ手順
  - [x] 初回デプロイの流れ

## フェーズ4: テスト・品質チェック

- [x] RSpec テストが通ることを確認する
  - [x] `bundle exec rspec` を実行
- [x] RuboCop リントエラーがないことを確認する
  - [x] `bundle exec rubocop` を実行

## フェーズ5: コミット・Issue更新

- [ ] 変更をコミットする（Issue #7 対応）
- [ ] GitHub にプッシュする
- [ ] Issue #7 を In Progress に移動する

---

## 実装後の振り返り

### 実装完了日
{YYYY-MM-DD}

### 計画と実績の差分

**計画と異なった点**:
- {記入予定}

### 学んだこと
- {記入予定}

### 次回への改善提案
- {記入予定}
