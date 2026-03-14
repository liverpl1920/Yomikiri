# 設計書

## 変更内容

`render.yaml` の `startCommand` を以下の通り変更する:

```yaml
# 修正前
startCommand: bundle exec rails db:migrate && bundle exec puma -C config/puma.rb

# 修正後
startCommand: bundle exec rails db:migrate && exec bundle exec puma -C config/puma.rb
```

## exec を使う理由

Unix の `exec` syscall はシェルプロセス自身を指定したプログラムに置き換える。これにより:

- puma がシェルの**子プロセスではなく**、メインプロセス（PID 1 相当）になる
- Render から送られる SIGTERM（グレースフルシャットダウン）が puma に直接届く
- プロセス終了コードが puma の終了コードとして正確に伝わる

## db:migrate の冪等性について

Rails の `db:migrate` はすでに適用済みのマイグレーションをスキップするため、毎回実行しても安全。free tier での再起動時のオーバーヘッドは軽微で許容範囲内。
