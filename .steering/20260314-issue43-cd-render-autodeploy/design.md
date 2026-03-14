# 設計書

## アーキテクチャ概要

Renderの Infrastructure as Code (IaC) として `render.yaml` を使用し、CDパイプラインを設定する。

```
mainブランチへのマージ
      ↓
Render (autoDeploy: true)
      ↓
buildCommand: bundle install + assets:precompile
      ↓
preDeployCommand: bundle exec rails db:migrate
      ↓
startCommand: bundle exec puma -C config/puma.rb
```

## コンポーネント設計

### 1. render.yaml

**責務**:
- Renderサービスの構成を定義する
- 環境変数のリストを管理する

**変更内容**:
- `preDeployCommand` を追加: `bundle exec rails db:migrate`
- `startCommand` から `db:migrate` を除去: `bundle exec puma -C config/puma.rb` のみ
- `autoDeploy: true` を追加
- `branch: main` を追加
- `SENDGRID_API_KEY` 環境変数を追加（`sync: false`）

### 2. Renderの設定項目の意味

| 項目 | 説明 |
|------|------|
| `preDeployCommand` | デプロイ前に実行するコマンド。失敗するとデプロイが中断される |
| `startCommand` | アプリ起動コマンド |
| `autoDeploy` | mainブランチへのpushで自動デプロイするか |
| `branch` | 監視するブランチ名 |

## データフロー

### デプロイフロー
```
1. PR が main にマージされる
2. Render が mainブランチの変更を検知（webhookまたはpolling）
3. buildCommand が実行される（bundle install, assets:precompile）
4. preDeployCommand が実行される（db:migrate）
   - 失敗した場合はデプロイが中断され、以前のバージョンが維持される
5. startCommand が実行される（puma起動）
6. healthCheckPath: /up でヘルスチェックが通ればデプロイ完了
```

## テスト戦略

### 手動確認
- Render Dashboard でデプロイログを確認
- `preDeployCommand` の `db:migrate` が実行されていることを確認
- ヘルスチェック `/up` が成功することを確認
