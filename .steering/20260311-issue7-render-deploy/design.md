# 設計書

## アーキテクチャ概要

Renderのネイティブ Ruby ランタイムを使用してデプロイする。データベースはRender内部ではなくNeon（外部PostgreSQL）を使用する。

```
ユーザー
  │ HTTPS
  ▼
Render（Web Service: yomikiri）
  │ runtime: ruby
  │ buildCommand: bundle install + assets:precompile
  │ startCommand: puma
  │
  │ DATABASE_URL（環境変数）
  ▼
Neon PostgreSQL（外部）
```

## コンポーネント設計

### 1. render.yaml

**責務**:
- Renderサービス定義（IaC）
- 環境変数・ビルド設定の宣言

**実装の要点**:
- `fromDatabase` 参照は使用しない（Neonは外部DB）
- `DATABASE_URL: sync: false` にすることでRenderダッシュボードで手動設定
- `RAILS_MASTER_KEY: sync: false` でRenderダッシュボードで手動設定
- `healthCheckPath: /up` でHelath checkエンドポイントを設定

### 2. config/database.yml

**責務**:
- 環境別データベース接続設定

**実装の要点**:
- production は `url: <%= ENV["DATABASE_URL"] %>` のみ
- Neon接続文字列はSSLモードが必要（`?sslmode=require`）

### 3. config/puma.rb

**責務**:
- Webサーバー設定

**実装の要点**:
- `PORT` 環境変数を参照（Renderが動的に割り当て）
- workers設定はRender Free Planの制限を考慮

### 4. README.md

**責務**:
- デプロイ手順の文書化

**実装の要点**:
- 必要な環境変数リスト
- Render + Neonセットアップ手順
- 初回デプロイの流れ

## データフロー

### 初回デプロイフロー
```
1. GitHubにコードをプッシュ
2. Render がrender.yamlを検出・サービスを作成
3. buildCommand 実行（bundle install, assets:precompile）
4. preDeployCommand 実行（rails db:migrate）
5. startCommand 実行（puma起動）
6. healthCheckPath (/up) で正常確認
```

### 環境変数設定フロー
```
1. NeonでPostgreSQLデータベースを作成
2. NeonのConnection StringをコピーURL + ?sslmode=require
3. RenderダッシュボードでDATABASE_URL を設定（sync: falseのため）
4. config/master.key の内容をRenderダッシュボードでRAILS_MASTER_KEY に設定
```

## エラーハンドリング戦略

### デプロイ失敗時
- Renderのデプロイログで `bundle install` または `assets:precompile` のエラーを確認
- `DATABASE_URL` 未設定の場合は `db:migrate` が失敗する
- `RAILS_MASTER_KEY` 未設定の場合はアプリ起動が失敗する

## テスト戦略

### ユニットテスト
- 特になし（インフラ設定のため）

### 統合テスト（手動確認）
- Render URL にアクセスしてTOPページが表示される
- `https://[render-url]/up` でヘルスチェックが200を返す

## 依存ライブラリ

新規追加なし（既存のpg gem、puma gemを使用）

## ディレクトリ構造

```
変更ファイル:
  render.yaml               # DATABASE_URL設定をNeon対応に修正
  README.md                 # デプロイ手順を追加
```

## 実装の順序

1. render.yaml 修正（fromDatabase → sync: false）
2. 本番環境設定ファイルの確認・必要なら修正
3. README.md にデプロイ手順を追記
4. RSpecテスト実行確認
5. コミット・プッシュ
