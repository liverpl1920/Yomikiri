# タスクリスト: 書影アイテムサイズ縮小 (ISSUE#203)

## フェーズ1: 準備

- [x] ステアリングファイルの作成（requirements.md, design.md, tasklist.md）
- [x] Gitブランチ作成（feature/#203-item-size-reduction）
- [x] 既存コードの調査（books.css, books/index.html.erb, books/show.html.erb）

## フェーズ2: CSSの変更

- [x] `.book-list` グリッドの `minmax` を 280px → 200px に縮小
- [x] `.book-card__cover-placeholder` のフォントサイズを 4rem → 3rem に縮小

## フェーズ3: 検証

- [x] RSpecを実行して既存テストが全て通過することを確認
- [x] RuboCopを実行してエラーがないことを確認

## フェーズ4: Git操作

- [ ] 変更をコミット (#203)
- [ ] リモートにプッシュ
- [ ] PRを作成
- [ ] CI確認

## 振り返り

（全タスク完了後に記載）
