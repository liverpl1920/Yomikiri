# タスクリスト - 統計ページ改善（Issue #209, #210, #221）

## フェーズ1: 準備

- [ ] feature ブランチ作成（feature/#209-210-221-stats-improvements）

## フェーズ2: データモデル (Issue #221)

- [ ] reading_logsにstart_page/end_pageカラムを追加するマイグレーション作成
- [ ] マイグレーション実行（docker compose経由）
- [ ] ReadingLogモデルにstart_page/end_pageを追加
- [ ] BooksController#create_reading_log_for_progress!でstart_page/end_pageを保存

## フェーズ3: サービス (Issue #209, #210, #221)

- [ ] ReadingReportSummaryServiceにcustomペリオードタイプを追加
- [ ] ReadingReportSummaryServiceにdaily_pagesを追加（日別ページ数）
- [ ] ReadingReportSummaryServiceにreading_log_detailsを追加（ログ詳細）

## フェーズ4: コントローラー (Issue #210)

- [ ] MypagesController#statsでcustomペリオードを処理
- [ ] カスタム期間のstart_date/end_dateパラメータを受け取り

## フェーズ5: ビュー (Issue #209, #210, #221)

- [ ] stats.html.erbにカスタム期間フォームを追加（Issue #210）
- [ ] stats.html.erbに日別ページ数グラフを追加（Issue #209）
- [ ] stats.html.erbに読書ログ詳細テーブルを追加（Issue #221）

## フェーズ6: CSS

- [ ] カスタム期間フォームのスタイル追加
- [ ] 日別グラフのスタイル追加
- [ ] 読書ログ詳細テーブルのスタイル追加

## フェーズ7: テスト

- [ ] ReadingReportSummaryServiceのテスト更新（daily_pages, custom期間, log詳細）
- [ ] MypagesController statsのリクエストスペック更新
- [ ] BooksControllerのreading_log作成テスト更新（start_page/end_page）

## フェーズ8: 検証

- [ ] bundle exec rspec 全通過確認
- [ ] bundle exec rubocop 全通過確認

## フェーズ9: コミット・PR

- [ ] コミット（#209 #210 #221 統計ページ改善）
- [ ] PR作成

## 振り返り
（全タスク完了後に記載）
