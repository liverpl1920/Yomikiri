# 要求内容

## 概要

Issue #7: Renderへの初回デプロイ。アプリケーションをRender上にデプロイし、PostgreSQL（Neon）との接続を本番環境で確立する。

## 背景

rails new・初期セットアップ（#5）とTOPページ（#6）が完了した。次のステップとして、早期デプロイ方針に従い、Week1のうちに本番環境を稼働させる。本番環境を早期に確立することで、デプロイに関する問題を早期に発見し、開発サイクル全体を通じてCIと連携した継続的デプロイを実現する。

## 実装対象の機能

### 1. render.yaml の修正（Neon対応）

- 現在の `fromDatabase` 参照をNeon外部データベース用の設定に変更
- `DATABASE_URL` をRenderダッシュボードで手動設定できるよう `sync: false` に設定
- 不要な内部データベース参照を削除

### 2. 本番環境設定の確認・整備

- `config/environments/production.rb` の設定確認
- `config/database.yml` の本番設定確認（DATABASE_URL使用）
- `config/puma.rb` のポート設定確認
- Gemfile.lock の存在確認

### 3. デプロイ手順ドキュメントの整備

- README.md にデプロイ手順・環境変数設定の記述を追加
- Renderダッシュボードでの設定手順を記載

## 受け入れ条件

### render.yaml
- [ ] `DATABASE_URL` が `sync: false` で設定されている（Neon外部DB用）
- [ ] Renderの内部データベース（fromDatabase）への参照がない
- [ ] ビルドコマンド・スタートコマンドが正しく設定されている
- [ ] preDeployCommand で `rails db:migrate` が実行される
- [ ] healthCheckPath が設定されている

### 本番環境設定
- [ ] `config/database.yml` の production が `DATABASE_URL` を使用している
- [ ] `config/puma.rb` が `PORT` 環境変数を参照している
- [ ] `RAILS_MASTER_KEY` が環境変数として設定される前提の設定になっている

### ドキュメント
- [ ] README.md にRenderデプロイ手順が記載されている
- [ ] 必要な環境変数リストが明記されている

## 成功指標

- Render上のURLにアクセスし、TOPページが正常に表示される
- データベース接続（Neon）が確立されている
- `rails db:migrate` が本番環境で正常に実行される

## スコープ外

以下はこのフェーズでは実装しません:

- Googleカレンダー連携
- メール送信設定（SendGrid）
- OAuth認証
- 本番環境でのActive Storage設定（本リリース）
- Render内部PostgreSQLの利用（Neonを使用）

## 参照ドキュメント

- `docs/architecture.md` - アーキテクチャ設計書（インフラ・デプロイ先）
- `docs/development-guidelines.md` - 開発ガイドライン
- `issue/ISSUE.md` - Issue #3（Week1・Renderへの初回デプロイ）
