# タスクリスト

## 🚨 タスク完全完了の原則

**このファイルの全タスクが完了するまで作業を継続すること**

### 必須ルール
- **全てのタスクを`[x]`にすること**
- 未完了タスク（`[ ]`）を残したまま作業を終了しない

---

## フェーズ1: ステアリングと要件整理

- [x] ステアリングファイルを作成する
	- [x] `.steering/20260527-issue-257/requirements.md` を作成
	- [x] `.steering/20260527-issue-257/design.md` を作成
	- [x] `.steering/20260527-issue-257/tasklist.md` を作成

- [x] Issue #257 の要件を確認する
	- [x] `gh issue view 257` で仕様を確認
	- [x] 既存の関連設定（`production.rb`, `storage.yml`, `books_helper.rb`, `views`, `spec`）を確認

## フェーズ2: 本体実装

- [x] production の Active Storage を S3 固定 + fail-fast 化
	- [x] S3 必須環境変数検証クラスを追加
	- [x] `config/environments/production.rb` の local フォールバックを削除
	- [x] 不足キーを明示するエラーメッセージを実装

- [x] 書影表示フォールバックを改善する
	- [x] `books_helper.rb` で URL 解析失敗時のログ出力を追加
	- [x] `books_controller.rb` の cover proxy 失敗経路にログ出力を追加
	- [x] 一覧/詳細の書影表示に onerror フォールバックを追加

## フェーズ3: テスト実装

- [x] 回帰テストを追加する
	- [x] S3 設定検証クラスの spec を追加
	- [x] 2冊連続アップロードで1冊目添付が維持される model spec を追加
	- [x] 書影フォールバック用マークアップの request spec を追加

## フェーズ4: 品質チェックと修正

- [x] 実装変更を implementation-validator で検証する
- [x] RSpec が通ることを確認する
	- [x] `bundle exec rspec`
- [x] RuboCop が通ることを確認する
	- [x] `bundle exec rubocop`
- [x] ~~npm test 実行結果を確認する~~（実装方針変更により不要: 本リポジトリは Rails + importmap 構成で `package.json` が存在しない）
	- [x] ~~`npm test`~~（理由: `Missing script: test`）
- [x] ~~npm run lint 実行結果を確認する~~（実装方針変更により不要: 本リポジトリは Rails + importmap 構成で `package.json` が存在しない）
	- [x] ~~`npm run lint`~~（理由: `Missing script: lint`）
- [x] ~~npm run typecheck 実行結果を確認する~~（実装方針変更により不要: 本リポジトリは Rails + importmap 構成で `package.json` が存在しない）
	- [x] ~~`npm run typecheck`~~（理由: `Missing script: typecheck`）

## フェーズ5: 振り返り

- [x] tasklist の振り返りを記入する

---

## 実装後の振り返り

### 実装完了日
2026-05-27

### 計画と実績の差分

**計画と異なった点**:
- implementation-validator の指摘を受け、`fetch_with_redirects` に相対リダイレクト対応（`URI.join`）を追加した。
- helper の URL バリデーション分岐を強化し、`http/https` 以外を明示的に除外するようにした。
- architecture ドキュメントに Active Storage 実運用方針の差分反映を追加した。

**新たに必要になったタスク**:
- `spec/helpers/books_helper_spec.rb` を新規追加し、添付優先・proxy変換・無効URL・URL生成失敗の分岐を明示的に検証した。
- `spec/config/production_active_storage_config_spec.rb` を追加し、production 設定への validator 組み込みを確認した。

**技術的理由でスキップしたタスク**:
- `npm test` / `npm run lint` / `npm run typecheck`
	- スキップ理由: Rails + importmap 構成で npm scripts 未定義（`Missing script`）
	- 代替実装: `bundle exec rspec` と `bundle exec rubocop` を実行

### 学んだこと

**技術的な学び**:
- production の Active Storage を fail-fast 化することで、デプロイ後の遅延障害より前に設定不備を検知できる。
- 画像フォールバックは「サーバー側URL妥当性 + クライアント側onerror」の二段構えが有効。

**プロセス上の改善点**:
- implementation-validator を検証前に通すことで、テストを回す前に潜在リスクを先回りで除去できた。

### 次回への改善提案

- Active Storage 実ファイル欠損時の監視を強化するため、404 カウントのメトリクス化を検討する。
- 本番設定検証を CI の pre-deploy チェックとして自動化する。
