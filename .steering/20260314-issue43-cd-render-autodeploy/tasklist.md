# タスクリスト

## 🚨 タスク完全完了の原則

**このファイルの全タスクが完了するまで作業を継続すること**

### 必須ルール
- **全てのタスクを`[x]`にすること**
- 「時間の都合により別タスクとして実施予定」は禁止
- 「実装が複雑すぎるため後回し」は禁止
- 未完了タスク（`[ ]`）を残したまま作業を終了しない

---

## フェーズ1: render.yaml の修正

- [x] `preDeployCommand: bundle exec rails db:migrate` を追加する
- [x] `startCommand` から `db:migrate` を除去し、pumaのみにする
- [x] `autoDeploy: true` を追加する
- [x] `branch: main` を追加する
- [x] `SENDGRID_API_KEY` 環境変数を追加する（`sync: false`）

## フェーズ2: 動作確認

- [ ] render.yaml の YAML 構文が正しいことを確認する
- [ ] feature ブランチを作成してPRを作成する
- [ ] CIが通ることを確認する

## フェーズ3: 振り返り

- [ ] tasklist.md に申し送り事項を記載する
