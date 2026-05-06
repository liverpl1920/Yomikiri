# Tasklist: Issue #166 Google Books API キー設定

## フェーズ1: コード変更

- [x] `search_by_title` に `GOOGLE_BOOKS_API_KEY` の key パラメータを追加する
- [x] `.env.example` に `GOOGLE_BOOKS_API_KEY` と `RAKUTEN_APPLICATION_ID` のプレースホルダーを追加する
- [x] `render.yaml` に `GOOGLE_BOOKS_API_KEY` と `RAKUTEN_APPLICATION_ID` のエントリを追加する

## フェーズ2: 検証

- [x] `bundle exec rspec` を実行して全テストが通過することを確認する（358 examples, 0 failures）
- [x] `bundle exec rubocop` を実行してエラーがないことを確認する

## フェーズ3: コミット・PR

- [ ] 変更をコミットする（メッセージ: `#166 Google Books API キーを環境変数で設定する`）
- [ ] `feature/#166-google-books-api-key` をリモートにプッシュする
- [ ] PR を作成して CI を確認する

---

## 振り返り（実装後に記載）

<!-- 実装完了後に記入 -->
