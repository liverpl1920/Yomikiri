# 要求内容

## 概要

PR #60 に対する Copilot レビューコメント2件への対応。`render.yaml` の `startCommand` におけるシグナル伝搬問題を修正する。

## 背景

PR #60 で Copilot から以下2件の指摘があった:

### コメント1: 再起動のたびに db:migrate が実行される問題
free tier 制約で `preDeployCommand` が使えないため、`startCommand` に `db:migrate` を入れることで再起動時にも毎回マイグレーションが走る。起動時間増加や同時実行リスクがある。

### コメント2: シグナル伝搬の問題（今回対応）
`cmd1 && cmd2` 形式では puma がシェルの子プロセスになり、停止シグナル（SIGTERM等）の伝搬やプロセス終了コードの扱いが不安定になる。`exec` を使い puma をメインプロセスとして起動すべき。

## 実装対象

### コメント2への対応（実装する）
`startCommand` の puma 起動前に `exec` を追加し、puma をシェルのメインプロセスとして起動する:

```yaml
# 修正前
startCommand: bundle exec rails db:migrate && bundle exec puma -C config/puma.rb

# 修正後
startCommand: bundle exec rails db:migrate && exec bundle exec puma -C config/puma.rb
```

### コメント1への対応（許容する・ドキュメント化）
free tier では `preDeployCommand` が使えないため、`startCommand` に `db:migrate` を含める運用は現時点で許容する。`db:migrate` は冪等（既に適用済みのマイグレーションは再実行されない）であり、起動時間の増加は許容範囲内。

## 受け入れ条件

- [ ] `startCommand` に `exec` が付与されている
- [ ] YAML 構文が正しい
- [ ] CI（RuboCop/Brakeman/RSpec）が GREEN

## スコープ外

- `preDeployCommand` の復活（free tier 非対応のため）
- 手動マイグレーション運用への変更
