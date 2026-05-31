# 要求内容

## 概要

Issue #270「本番環境のActive Storage保存先をBackblaze B2へ切り替える」を解決するため、production の Active Storage 保存先を Backblaze B2（S3互換）へ移行し、本番での書影アップロードを成立させる。

## 背景

- 現在の production は S3 前提の設定になっているが、本番環境では AWS 系の環境変数が用意されていない。
- `DATABASE_URL` はデータベース接続先であり、Active Storage のファイル実体を保存する場所ではない。
- Backblaze B2 は S3 互換で利用できるため、保存先を B2 に切り替えることで本番のアップロード機能を成立させられる。

## 実装対象の機能

### 1. production の Active Storage を Backblaze B2 に切り替える
- production の Active Storage サービスを Backblaze B2 用に固定する。
- B2 用の必須環境変数を検証し、不足時は起動失敗にする。
- AWS 前提の環境変数名を B2 向けに整理する。

### 2. 本番デプロイ設定の更新
- Render の環境変数定義を B2 用に更新する。
- 設定手順や運用メモに B2 の必要項目を反映する。

### 3. 回帰テストの追加
- production 設定が B2 向け validator と Backblaze B2 サービスを参照することをテスト化する。
- B2 必須環境変数の検証をテスト化する。

## 受け入れ条件

### production の Active Storage 切り替え
- [ ] production で Backblaze B2 向けの必須環境変数が欠けると起動時に例外が発生する。
- [ ] production で Active Storage は Backblaze B2 サービスに固定される。
- [ ] B2 用の環境変数名がコードとドキュメントで一致している。

### 本番デプロイ設定
- [ ] Render の環境変数一覧が B2 用に更新されている。
- [ ] 既存の書籍登録・編集・表示機能に回帰がない。

### 回帰テスト
- [ ] B2 必須環境変数チェックのテストが追加される。
- [ ] production 設定の切り替えを確認するテストが追加される。
- [ ] RSpec / RuboCop が通過する。

## 成功指標

- production 起動時に B2 設定不備を即検知できる。
- 本番でアップロードした書影が Backblaze B2 に保存される前提がコード上で保証される。
- 環境変数名とドキュメントの不整合がない。

## スコープ外

以下はこのフェーズでは実装しません:

- 既存の Active Storage blob の一括移行ツール
- Render ダッシュボード上での実際の環境変数入力作業
- 画像表示 UI の追加改善

## 参照ドキュメント

- `docs/architecture.md` - アーキテクチャ設計書
- `docs/development-guidelines.md` - 開発ガイドライン
- `config/environments/production.rb` - 本番設定
- `config/storage.yml` - Active Storage 設定
- `render.yaml` - Render デプロイ設定
- `README.md` - 環境変数・デプロイ手順
