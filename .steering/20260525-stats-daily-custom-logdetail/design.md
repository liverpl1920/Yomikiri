# 設計 - 統計ページ改善（Issue #209, #210, #221）

## アーキテクチャ概要

### データモデル変更 (Issue #221対応)
`reading_logs`テーブルに`start_page`と`end_page`を追加:
- `start_page`: integer, nullable（読み始めたページ）
- `end_page`: integer, nullable（読み終わったページ）

進捗更新時 (`BooksController#create_reading_log_for_progress!`) で`start_page`=previous_page, `end_page`=current_pageを保存する。

### サービス変更 (Issue #209, #210, #221対応)
`ReadingReportSummaryService`を以下の点で拡張:
- `:custom`期間タイプを追加（start_date/end_dateを直接受け取る）
- `daily_pages`を返す: `{date => pages_read}` のHash（日別ページ数）
- `reading_log_details`を返す: 読書ログ詳細の配列

### コントローラー変更 (Issue #210対応)
`MypagesController#stats`を拡張:
- `custom`期間を受け付ける
- start_date/end_dateパラメータをサービスに渡す
- バリデーション（end >= start, 上限期間など）

### ビュー変更
`stats.html.erb`を拡張:
- 期間タブに「カスタム期間」を追加（日付入力フォーム）
- 日別ページ数のシンプルなバーグラフ/テーブルを追加
- 読書ログ詳細テーブル（本名・開始ページ・終了ページ）を追加

## 設計判断
- 日別グラフはChart.jsなどのライブラリを使わず、CSSのみでシンプルなバーグラフを実装（既存UIパターンに合わせる）
- カスタム期間の上限は設けない（実用上問題なし）
- start_page/end_pageはnullableとし、既存データとの後方互換性を保つ
