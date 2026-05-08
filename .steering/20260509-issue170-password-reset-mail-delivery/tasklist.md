# タスクリスト

## 🚨 タスク完全完了の原則

**このファイルの全タスクが完了するまで作業を継続すること**

---

## フェーズ1: コントローラーの障害耐性実装

- [x] `app/controllers/users/passwords_controller.rb` に送信例外ハンドリングを実装する
	- [x] `create` をオーバーライドして Devise 標準処理を呼び出す
	- [x] SMTP/接続関連例外を rescue してログ出力する
	- [x] ユーザー向けに汎用エラーメッセージを表示して再試行導線へ遷移する

## フェーズ2: テスト追加

- [x] `spec/requests/passwords_spec.rb` にメール送信例外時の異常系テストを追加する
	- [x] `send_reset_password_instructions` 例外発生時に 500 にならないことを検証
	- [x] リダイレクト先とフラッシュメッセージを検証

## フェーズ3: 品質検証

- [x] RSpec を実行して通過を確認する
	- [x] `bundle exec rspec`
- [x] RuboCop を実行して通過を確認する
	- [x] `bundle exec rubocop`
- [x] 実装品質検証サブエージェントを実行する
	- [x] implementation-validator の指摘事項に対応する（必要時）

## フェーズ4: add-feature プロンプト要件の確認

- [x] ~~`npm test` 実行結果を確認する~~（理由: 本リポジトリは Rails + importmap 構成で package.json の test スクリプト未定義のため）
- [x] ~~`npm run lint` 実行結果を確認する~~（理由: 本リポジトリは Rails + importmap 構成で package.json の lint スクリプト未定義のため）
- [x] ~~`npm run typecheck` 実行結果を確認する~~（理由: 本リポジトリは Rails + importmap 構成で package.json の typecheck スクリプト未定義のため）

## フェーズ5: 振り返り

- [x] 実装後の振り返りを記載する

---

## 実装後の振り返り

### 実装完了日
2026-05-09

### 計画と実績の差分

**計画と異なった点**:
- implementation-validator の指摘により、例外捕捉範囲から `IOError` を除外して配信障害に限定した。
- ログ要件を担保するため、request spec に `Rails.logger.error` の呼び出し検証を追加した。

**新たに必要になったタスク**:
- 非推奨ステータスシンボル対応として、`spec/requests/passwords_spec.rb` の `:unprocessable_entity` を `:unprocessable_content` に更新した。

**技術的理由でスキップしたタスク**（該当する場合のみ）:
- `npm test` / `npm run lint` / `npm run typecheck`
	- スキップ理由: package.json の各スクリプトが未定義で、Rails 本体の品質確認手段として採用されていないため。
	- 代替実装: `bundle exec rspec` と `bundle exec rubocop` を実行して品質確認を完了。

### 学んだこと

**技術的な学び**:
- Devise の `PasswordsController#create` は配信例外を標準で吸収しないため、運用系障害を UI 崩壊に繋げないにはアプリ側境界での rescue が有効。
- request spec で logger を検証する場合は logger 全体を差し替えず、`allow(Rails.logger).to receive(:error)` の部分スタブが安全。

**プロセス上の改善点**:
- サブエージェント検証を早めに入れると、例外範囲の過不足や観点漏れ（ログ検証不足）を実装途中で是正しやすい。

### 次回への改善提案
- アプリ全体で `:unprocessable_entity` の残存箇所を段階的に `:unprocessable_content` へ統一する。
- メール障害時の運用検知を強化するため、将来的に監視サービス（例: Sentry）への通知連携を検討する。
