# Tasklist: Issue #166 Google Books API キー設定

## フェーズ1: コード変更

- [x] `search_by_title` に `GOOGLE_BOOKS_API_KEY` の key パラメータを追加する
- [x] `.env.example` に `GOOGLE_BOOKS_API_KEY` と `RAKUTEN_APPLICATION_ID` のプレースホルダーを追加する
- [x] `render.yaml` に `GOOGLE_BOOKS_API_KEY` と `RAKUTEN_APPLICATION_ID` のエントリを追加する

## フェーズ2: 検証

- [x] `bundle exec rspec` を実行して全テストが通過することを確認する（358 examples, 0 failures）
- [x] `bundle exec rubocop` を実行してエラーがないことを確認する

## フェーズ3: コミット・PR

- [x] 変更をコミットする（メッセージ: `#166 Google Books API キーを環境変数で設定する`）
- [x] `feature/#166-google-books-api-key` をリモートにプッシュする
- [x] PR #167 を作成して CI を確認する（CI: success）

---

## 振り返り（実装後に記載）

### 実装完了日
2026-05-06

### 計画と実績の差分
- 計画どおり3ファイル（`books_controller.rb`, `.env.example`, `render.yaml`）のみ変更で完了
- テスト追加は不要（既存の WebMock スタブが正規表現マッチのため `key=` パラメータ追加後も全通過）

### 学んだこと
- `ENV["KEY"].presence` を使うことで、未設定時にパラメータを付けないシンプルな条件分岐が書ける
- `render.yaml` の `sync: false` はシークレット値をダッシュボードのみで管理するための慣習的な書き方
- `RAKUTEN_APPLICATION_ID` は別 Issue で実装済みだが、環境変数定義の整備をこの Issue で合わせて行えた

### 次回への改善提案
- ローカル開発環境のセットアップ手順（`.env` へのキー設定方法）を `README.md` に明記するとよい
- Render ダッシュボードでのキー設定手順も `docs/development-workflow.md` に追記することを推奨
