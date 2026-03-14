# 要求内容

## 概要

Issue #43: CDパイプラインの設計・Render自動デプロイ設定。`render.yaml` を正しく整備し、mainブランチへのマージで自動デプロイが動作するようにする。

## 背景

現在の `render.yaml` には以下の問題がある:
- `db:migrate` が `startCommand` に含まれており、Renderの推奨する `preDeployCommand` を使っていない
- `SENDGRID_API_KEY` 環境変数が定義されていない
- `autoDeploy` の設定が明示されていない

## 実装対象の機能

### 1. preDeployCommand の設定
- `db:migrate` を `startCommand` から `preDeployCommand` に移動する
- `startCommand` はpumaの起動のみにする

### 2. 環境変数の追加
- `SENDGRID_API_KEY` を環境変数として定義する（`sync: false` で手動設定）

### 3. 自動デプロイ設定
- `autoDeploy: true` を設定し、mainブランチへのマージで自動デプロイを有効にする
- `branch: main` を明示する

## 受け入れ条件

### render.yaml の設定
- [ ] `render.yaml` がリポジトリに存在し、Render が認識できる形式である
- [ ] `preDeployCommand: bundle exec rails db:migrate` が設定されている
- [ ] `startCommand` が `bundle exec puma -C config/puma.rb` のみになっている
- [ ] `autoDeploy: true` が設定されている
- [ ] `SENDGRID_API_KEY` が環境変数として定義されている

### CI/CD フロー
- [ ] mainにマージされると自動でデプロイが開始される（Render Dashboard確認）

## スコープ外

以下はこのフェーズでは実装しません:
- Render Dashboard での手動設定（Auto-Deploy の有効化はrender.yamlで制御）
- freebusy API などの高度な機能

## 参照ドキュメント

- `docs/architecture.md` - アーキテクチャ設計書
- `render.yaml` - 既存のRender設定ファイル
