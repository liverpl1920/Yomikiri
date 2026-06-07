# 設計書

## アーキテクチャ概要

本機能はRails標準のMVCパターンに基づき実装します。
`/dashboard` へのリクエストは `DashboardsController#show` で処理され、必要なデータを集計した上で `app/views/dashboards/show.html.erb` を描画します。
フロントエンドは `app/assets/stylesheets/dashboards.css` でForest Nookテーマを適用します。

```
┌──────────────────────────────────────────────────┐
│                     Browser                      │
└───────────────────────┬──────────────────────────┘
                        │ GET /dashboard
                        ▼
┌──────────────────────────────────────────────────┐
│                     Routes                       │
│      resource :dashboard, only: [ :show ]        │
└───────────────────────┬──────────────────────────┘
                        ▼
┌──────────────────────────────────────────────────┐
│              DashboardsController                │
│  - @reading_books                                │
│  - @total_daily_quota                            │
│  - @recent_completed_books                       │
│  - @total_books_read, @total_pages_read          │
│  - @streak_days (読書記録基準のストリーク日数)     │
│  - @weekly_activity (過去7日間の日別集計データ)   │
└───────────────────────┬──────────────────────────┘
                        ▼
┌──────────────────────────────────────────────────┐
│                      Views                       │
│     app/views/dashboards/show.html.erb           │
└──────────────────────────────────────────────────┘
```

## コンポーネント設計

### 1. DashboardsController (app/controllers/dashboards_controller.rb)

**責務**:
- ユーザーのダッシュボードに必要な以下のデータを集計する。
  - **進行中の書籍 (@reading_books)**: ステータスが `reading` の本。期限が近い順。
  - **今日の総ノルマ (@total_daily_quota)**: `@reading_books` の `daily_quota` の合計。
  - **最近読了した本 (@recent_completed_books)**: ステータスが `completed` の本。最大3冊。読了日の降順。
  - **総読了冊数 (@total_books_read)**: ステータスが `completed` の本。
  - **総読了ページ数 (@total_pages_read)**: ユーザーの全読書ログ (`ReadingLog`) の `pages_read` の合計。
  - **読書ストリーク日数 (@streak_days)**: `ReadingLog` の `read_at` に基づく連続読書日数。
  - **週次アクティビティ (@weekly_activity)**: 過去7日間の日別読了ページ数のハッシュ。

**実装の要点**:
- 連続読書日数（ストリーク）の計算ロジック:
  1. ユーザーに関連する `ReadingLog` のユニークな `read_at` を降順ソートして取得。
  2. 最新の読書日が「今日」か「昨日」であるかを確認。いずれでもない場合はストリークは 0。
  3. 最新の読書日から過去に遡って、連続する日付が存在する限りカウント。
- 週次アクティビティ:
  1. `Date.current - 6.days` から `Date.current` までの範囲で `ReadingLog` の `pages_read` を日付ごとにグループ化して合計。
  2. 存在しない日付はページ数 0 とする。

### 2. ダッシュボードビュー (app/views/dashboards/show.html.erb)

**責務**:
- Forest Nook テーマに基づく美しいレイアウトでダッシュボードを表示する。

**実装の要点**:
- Welcome ヘッダー
- グリッドレイアウトを使用したコンポーネント配置
- CSSのみによるアクティビティ棒グラフの表現（グラフの最大値に応じた比率計算を行い、高さを動的に設定）

### 3. ダッシュボードスタイルシート (app/assets/stylesheets/dashboards.css)

**責務**:
- グリッドレイアウト、統計カード、アクティビティ棒グラフなどのビジュアル表現。

## データフロー

### ダッシュボード表示
1. ユーザーが `/dashboard` にアクセス。
2. `DashboardsController#show` が呼び出され、データベースから該当ユーザーの `Book` 及び `ReadingLog` データを取得・計算。
3. `show.html.erb` がレンダリングされ、HTMLとCSSがユーザーに表示される。

## テスト戦略

### ユニットテスト (spec/requests/dashboards_spec.rb)
- ログイン中のユーザーがダッシュボードを正常に表示できること。
- 未ログインのユーザーがダッシュボードにアクセスした場合、ログイン画面にリダイレクトされること。
- コントローラー内でのストリーク計算および週次アクティビティ集計が正しく動作すること。

### システムテスト (spec/system/dashboards_spec.rb)
- ダッシュボードの各セクション（進行中の本、読書統計、目標進捗、アクティビティグラフ、最近読了した本）が正しく画面上に描画されること。

## ディレクトリ構造

```text
app/
├── controllers/
│   ├── dashboards_controller.rb  [NEW]
│   └── users/
│       └── sessions_controller.rb (after_sign_in_path_for 修正)
├── assets/
│   └── stylesheets/
│       ├── dashboards.css        [NEW]
│       ├── application.css      (CSS変数・テーマ更新)
│       └── header_footer.css    (ヘッダーデザイン修正)
└── views/
    ├── dashboards/
    │   └── show.html.erb         [NEW]
    └── shared/
        └── _header.html.erb     (ダッシュボードリンク追加)
config/
└── routes.rb                    (ルーティング追加)
spec/
├── requests/
│   └── dashboards_spec.rb        [NEW]
└── system/
    └── dashboards_spec.rb        [NEW]
```

## 実装の順序

1. 基本設定とタイポグラフィの適用（Google Fonts, CSS変数の更新）
2. ルーティングの追加
3. ヘッダーメニューの更新とログイン後リダイレクト先の修正
4. `DashboardsController` の作成と計算ロジック実装
5. `app/views/dashboards/show.html.erb` の作成
6. `app/assets/stylesheets/dashboards.css` の作成
7. テストコードの作成と検証実行（RSpec & RuboCop）

## セキュリティ考慮事項

- `before_action :authenticate_user!` による未ログインアクセスの保護。
- データベースからデータを取得する際、必ず `current_user` に紐づくデータにスコープする。

## パフォーマンス考慮事項

- `ReadingLog` の取得や集計クエリにおける N+1 問題の回避。進行中の書籍読み込み時の効率化。

## 将来の拡張性

- 進行中の書籍カード内で、直接「進捗更新」ができるような Stimulus コントローラーまたは Turbo Streams によるインプレース更新への拡張を見据えたHTML構造にする。
