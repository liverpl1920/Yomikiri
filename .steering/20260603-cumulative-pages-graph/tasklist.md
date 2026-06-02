# タスクリスト

## 🚨 タスク完全完了の原則

**このファイルの全タスクが完了するまで作業を継続すること**

---

## フェーズ1: 現状調査

- [x] 既存のグラフ描画ロジックの調査
  - [x] コントローラーでのデータ取得箇所の特定 (`BooksController#prepare_progress_chart_data`)
  - [x] フロントエンドでの描画ロジックの特定 (`app/views/books/show.html.erb` の SVG 部分)

## フェーズ2: 実装

- [ ] `BooksController#prepare_progress_chart_data` の修正
  - [ ] 累積読了ページ数を計算するロジックの追加
  - [ ] 日毎のデータに `cumulative_pages` を含める
  - [ ] `@progress_chart_max_pages` を累積値の最大（＝その期間の最後の累積値）に更新
- [ ] `app/views/books/show.html.erb` の修正
  - [ ] SVG の描画ロジックで `cumulative_pages` を使用するように変更
  - [ ] 縦軸のラベルやタイトルを「累積ページ数」に合わせる
  - [ ] テーブル表示も累積ページ数に変更するか検討（Issueの要件に合わせて調整）
- [ ] 翻訳ファイルの更新（必要に応じて）

## フェーズ3: 品質チェックと修正

- [ ] 累積計算が正しいか、特にログがない日の処理を確認
- [ ] 既存のテストが通ることを確認
  - [ ] `bundle exec rspec spec/requests/books_spec.rb`
- [ ] リントエラーがないことを確認
  - [ ] `bundle exec rubocop`

## フェーズ4: ドキュメント更新

- [ ] 実装後の振り返り

---

## 実装後の振り返り
