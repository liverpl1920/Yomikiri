# タスクリスト：Issue #374 全画面著者省略表示の統一適用

## フェーズ1: ステアリングファイル作成

- [x] `.steering/20260620-issue374-author-display-all-screens/requirements.md` 作成
- [x] `.steering/20260620-issue374-author-display-all-screens/design.md` 作成
- [x] `.steering/20260620-issue374-author-display-all-screens/tasklist.md` 作成（本ファイル）

## フェーズ2: ブランチ作成

- [x] `git checkout main && git pull origin main`
- [x] `git checkout -b feature/#374-author-display-all-screens`

## フェーズ3: ビュー修正

- [x] `books/show.html.erb` の著者表示を `book_author_display(@book)` に変更
- [x] `dashboards/show.html.erb` の読書中書籍の著者表示を `book_author_display(book)` に変更
- [x] `dashboards/show.html.erb` の最近読了した本の著者表示を `book_author_display(book)` に変更
- [x] `dashboards/_random_lookback.html.erb` の著者表示を `book_author_display(random_book)` に変更
- [x] `mypages/show.html.erb` の読了履歴の著者表示を `book_author_display(book)` に変更

## フェーズ4: 検証

- [x] `bundle exec rspec` で全テスト実行
- [x] `bundle exec rubocop` で Lint 確認

## フェーズ5: コミット・プッシュ・PR作成

- [ ] `git add .`
- [ ] `git commit -m "feat: 全画面で著者省略表示を統一適用 (#374)"`
- [ ] `git push origin feature/#374-author-display-all-screens`
- [ ] `gh pr create` でPR作成

## 振り返り

（完了後に記載）
