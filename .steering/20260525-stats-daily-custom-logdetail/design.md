# 設計 - 統計ページ改善（Issue #209, #210, #221）

## アーキテクチャ概要

### データモデル変更 (Issue #221対応)
`reading_logs`テーブルに`start_page`と`end_page`を追加:
- `start_page`: integer, nullable（読み始めたページ番号。1始まり）
- `end_page`: integer, nullable（読み終えたページ番号。1始まり）

**定義**: `current_page`は「最後に読み終えたページ」を表すため:
- `start_page = previous_page + 1`（例: 0→30の場合、start_page=1, end_page=30）
- `end_page = current_page`
- 両方nilは許容（旧データとの後方互換）、片方だけはモデルバリデーションで禁止

### サービス変更 (Issue #209, #210, #221対応)
`ReadingReportSummaryService`を以下の点で拡張:
- `:custom`期間タイプを追加（start_date/end_dateを直接受け取る）
- `daily_pages`を返す: `{date => pages_read}` のHash（日別ページ数）
- `reading_log_details`を返す: 読書ログ詳細の配列

### コントローラー変更 (Issue #210対応)
`MypagesController#stats`を拡張:
- `custom`期間を受け付ける
- start_date > end_dateの場合は自動でスワップ（バリデーションエラーではなくUX優先）
- start_date/end_dateパラメータをサービスに渡す
- 上限: MAX_CUSTOM_PERIOD_DAYS = 366日（パフォーマンス保護）

### ビュー変更
`stats.html.erb`を拡張:
- 期間タブに「カスタム期間」を追加（日付入力フォーム）
- 日別ページ数のシンプルなバーグラフ/テーブルを追加
- 読書ログ詳細テーブル（本名・開始ページ・終了ページ）を追加

## 設計判断
- 日別グラフはChart.jsなどのライブラリを使わず、CSSのみでシンプルなバーグラフを実装（既存UIパターンに合わせる）
- カスタム期間の上限はMAX_CUSTOM_PERIOD_DAYS = 366日（サービス層で強制）
- start_page/end_pageはnullableとし、既存データとの後方互換性を保つ
