# 設計書

## アーキテクチャ概要

本機能は、Railsの標準的なMVCアーキテクチャパターンおよびサービス層パターンに従い実装します。

```
[MypagesController]
       │
       ▼
[ReadingReportSummaryService] ── (ReadingLog/Bookを結合・集計)
       │
       ▼
[mypages/stats.html.erb] ──── (CSS割合バーによる可視化)
```

## コンポーネント設計

### 1. ReadingReportSummaryService

**責務**:
- 指定期間の読書記録を抽出し、ジャンル別の読了ページ数および比率（％）を算出する。

**実装の要点**:
- `scoped_logs` (期間内の読書記録) を基に、関連する `Book` の `genre` でグループ化して `pages_read` を合計。
- `books.genre` が `nil` または空文字のものは `未分類` として集計。
- 集計した各ジャンルの読了ページ数から、期間内の総読了ページ数に対する比率（％）を計算（小数点第1位で四捨五入）。
- 結果を `pages_read` の降順（同数の場合はジャンル名順）でソートして配列で返す。
- 総読了ページ数が 0 の場合は比率も 0 とする。

返り値のデータ構造（`@summary[:genres]`）:
```ruby
[
  { name: 'バックエンド', pages_read: 120, ratio: 60.0 },
  { name: '未分類', pages_read: 80, ratio: 40.0 }
]
```

### 2. MypagesController

**責務**:
- `ReadingReportSummaryService` から取得した集計結果をビューに受け渡す。
- 特に追加のロジックは必要とせず、`@summary` からビューで集計データを直接利用できるようにする。

### 3. mypages/stats.html.erb

**責務**:
- 「ジャンル別読書ポートフォリオ」セクションを追加し、結果を表示する。
- 既存の「日別読了ページ数」や「書籍別の読了ページ内訳」と同様に、レスポンシブな割合バー（CSS）を用いて美しく可視化する。

**CSSの実装**:
- `app/assets/stylesheets/mypages.css` にジャンルグラフ用のスタイルを追加。
- 視覚的区別のために、ジャンルグラフには紫色の美しいグラデーション（`linear-gradient(90deg, #7c3aed 0%, #a78bfa 100%)`）を採用。

## データフロー

### 統計ページの表示（ジャンル別ポートフォリオ）
```
1. ユーザーが mypage/stats にアクセス（期間パラメータ付き）
2. MypagesController#stats が起動
3. ReadingReportSummaryService.call を実行し、期間内の読書実績とジャンル別の集計を実行
4. サービスがジャンル別のページ数と比率を計算し、ソート済みの配列を返す
5. コントローラがビューをレンダリングし、ジャンル別グラフを割合バーで表示
```

## テスト戦略

### ユニットテスト (RSpec)
- `spec/services/reading_report_summary_service_spec.rb` を追加、または既存のテストにジャンル集計のスペックを追加。
- 以下のケースを検証：
  - ジャンルが設定されている書籍の集計が正しいこと。
  - ジャンルが未設定の書籍が「未分類」として集計されること。
  - 読書ログが存在しない期間の場合、空の配列が返ること。
  - 比率の計算が正しく（合計100%付近、端数処理など）、ソート順が降順であること。

### 統合テスト (System Spec)
- `spec/system/mypages_spec.rb` が存在する場合はそこに追加。存在しない場合は新規作成するか、適切なシステムテストで確認。
- 統計画面に「ジャンル別読書ポートフォリオ」セクションが表示されていること、グラフが表示されていること。

## ディレクトリ構造

```
app/
 ├── controllers/
 │    └── mypages_controller.rb (既存: 変更不要、または変数確認)
 ├── services/
 │    └── reading_report_summary_service.rb (既存: 変更)
 ├── views/
 │    └── mypages/
 │         └── stats.html.erb (既存: 変更)
 └── assets/
      └── stylesheets/
           └── mypages.css (既存: 変更)
spec/
 └── services/
      └── reading_report_summary_service_spec.rb (既存: 変更または追加)
```

## 実装の順序

1. `ReadingReportSummaryService` にジャンル別集計ロジックを実装。
2. `ReadingReportSummaryService` のユニットテストを追加・実行。
3. `mypages.css` にジャンル用グラデーションスタイルを追加。
4. `stats.html.erb` ビューに「ジャンル別読書ポートフォリオ」を表示するHTMLを追加。
5. ローカルサーバーやRSpec/System Specで動作確認と表示の崩れがないか検証。
