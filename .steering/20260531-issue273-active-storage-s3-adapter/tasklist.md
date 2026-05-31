# タスクリスト

## 🚨 タスク完全完了の原則

このファイルの全タスクが完了するまで作業を継続すること。

## フェーズ1: 依存関係の実装

- [x] `Gemfile` の `aws-sdk-s3` 定義を確認し、不足していれば追加
- [x] `Gemfile.lock` の `aws-sdk-s3` と関連依存を確認

## フェーズ2: 回帰防止テスト

- [x] Active Storage 設定テストを実行
	- [x] `bundle exec rspec spec/config/storage_config_spec.rb spec/config/production_active_storage_config_spec.rb spec/services/active_storage_s3_config_validator_spec.rb`
- [x] RuboCop を実行
	- [x] `bundle exec rubocop`

## フェーズ3: 実装検証

- [x] implementation-validator エージェントで品質確認

## フェーズ4: ドキュメントと振り返り

- [x] `tasklist.md` の振り返りを記載

---

## 実装後の振り返り

### 実装完了日
2026-05-31

### 計画と実績の差分

計画と異なった点:
- add-feature 手順に含まれる `npm test` / `npm run lint` / `npm run typecheck` は本リポジトリに npm scripts が定義されておらず実行不可だった。
- 代替として、この Rails リポジトリの標準品質ゲートである対象 RSpec と RuboCop の通過で検証を完了した。

新たに必要になったタスク:
- なし

技術的理由でスキップしたタスク（該当する場合のみ）:
- npm scripts 実行確認（理由: `package.json` に `test` / `lint` / `typecheck` が存在しないため。品質確認は `bundle exec rspec` と `bundle exec rubocop` に置き換え）

### 学んだこと

技術的な学び:
- `config/storage.yml` で `service: S3` を使う構成では、`aws-sdk-s3` の依存が欠けると Active Storage 初期化時に起動失敗する。
- B2 環境変数の fail-fast バリデーションだけでは不十分で、S3 アダプタ依存の明示が必要。

プロセス上の改善点:
- リポジトリごとのテスト実行基盤（npm か bundle か）をタスク化時点で明確化すると手戻りを減らせる。

### 次回への改善提案
- 設定ファイル文字列の include テストに加え、Active Storage サービス解決まで行う起動スモークテストを CI に追加する。
