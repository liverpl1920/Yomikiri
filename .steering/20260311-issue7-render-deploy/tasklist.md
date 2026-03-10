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

- [x] 変更をコミットする（Issue #7 対応）
- [x] GitHub にプッシュする
- [x] Issue #7 を In Progress に移動する

---

## 実装後の振り返り

### 実装完了日
2026-03-11

### 計画と実績の差分

**計画と異なった点**:
- `render.yaml` は既存ファイルとして存在したが、未コミット状態だった。今回のISSUEで初めてコミット対象とした
- `DATABASE_URL` の `fromDatabase` 参照は、Neon（外部DB）方針に反していたため修正が必要だった（既存ファイルのバグ修正として対応）
- 本番環境設定ファイル（database.yml, puma.rb, production.rb）はすでに適切に設定されていたため、修正不要だった

### 学んだこと
- Renderの `render.yaml` で `fromDatabase` を使うのはRender管理の内部DBを使う場合のみ。Neon等の外部DBは `sync: false` で手動設定する
- Render Free Planではサービスがスリープする（15分間アクセスなし）ため、初回アクセスに時間がかかる点を README に明記することが重要
- デプロイ設定ファイルは実際の動作確認（Renderへの実際のデプロイ）が完了条件のため、インフラ側での手動操作が別途必要

### 次回への改善提案
- Renderへの実際のデプロイ実行（NeonのDATABASE_URL設定、RAILS_MASTER_KEY設定）は手動作業のため、本ISSUEクローズ前にRenderダッシュボードでの確認が必要
- `render.yaml` の Blueprint機能を活用して、Renderダッシュボードからの自動セットアップを試すとよい

### PRリンク
https://github.com/liverpl1920/Yomikiri/pull/57
