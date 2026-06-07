# 設計書

## アーキテクチャ概要

本機能は、既存の MVC アーキテクチャ及びダッシュボードの表示ロジックに基づいて動作します。
コントローラ層 (`DashboardsController`) が取得した `@random_book` オブジェクトを、パーシャルビュー (`app/views/dashboards/_random_lookback.html.erb`) 内で表示し、表示スタイルは CSS (`app/assets/stylesheets/dashboards.css`) によって調整します。

## コンポーネント設計

### 1. ビュー (`app/views/dashboards/_random_lookback.html.erb`)

**責務**:
- 過去の読了本 (`random_book`) のタイトルや著者の下に、読了日を表示する。
- 読了日は I18n を使用してローカライズする。

**実装の要点**:
- `random_book.completed_at` が存在する場合は `l(random_book.completed_at.to_date)` を使用してローカライズ表示する。
- nil などの場合は `l` メソッドでの例外を避けるため、存在チェックをして「不明」とフォールバックする。

### 2. ローカライズ設定 (`config/locales/ja.yml`, `config/locales/en.yml`)

**責務**:
- 読了日のラベルと言語ごとの表示形式を管理する。

**キー**:
- `dashboards.lookback.completed_at`
  - `ja`: `"読了日: %{date}"`
  - `en`: `"Read on: %{date}"`

### 3. スタイルシート (`app/assets/stylesheets/dashboards.css`)

**責務**:
- 新たに表示される読了日テキストのスタイルを調整し、フォントサイズやマージンが周囲の著者名などと調和するようにする。

**実装の要点**:
- `.lookback-card__completed-at` を定義し、フォントサイズ `11px`、カラー `var(--color-text-muted)`、`margin-top: 2px` とする。

## テスト戦略

### システムテスト (`spec/system/dashboards_spec.rb`)
- 過去に読了した本が表示されたとき、「過去の読書からの発掘」のカード内に「読了日: YYYY/MM/DD」が表示されていることを確認する。
- 英語ロケールでの表示、および `completed_at` が nil の場合の表示についても確認・対応する。

## ディレクトリ構造

```
app/
  assets/
    stylesheets/
      dashboards.css (変更)
  views/
    dashboards/
      _random_lookback.html.erb (変更)
config/
  locales/
    ja.yml (変更)
    en.yml (変更)
spec/
  system/
    dashboards_spec.rb (変更)
```

## 実装の順序

1. Git ブランチの作成
2. 翻訳ファイルの更新 (`ja.yml`, `en.yml`)
3. ビューファイルの更新 (`_random_lookback.html.erb`)
4. スタイルシートの更新 (`dashboards.css`)
5. システムテストの更新 (`dashboards_spec.rb`)
6. テスト実行と RuboCop による検証
