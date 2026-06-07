# タスクリスト

## 🚨 タスク完全完了の原則

**このファイルの全タスクが完了するまで作業を継続すること**

### 必須ルール
- **全てのタスクを`[x]`にすること**
- 未完了タスク（`[ ]`）を残したまま作業を終了しない

---

## フェーズ1: 基本設計と環境構築

- [x] デザインテーマ (Forest Nook) の基礎準備
  - [x] `app/views/layouts/application.html.erb` に Google Fonts 読み込みタグを追加する（※ユーザー指示により不要になりスキップ）
  - [x] `app/assets/stylesheets/application.css` に `:root` 内の CSS カラー変数、タイポグラフィ変数を定義し、見出しフォントの設定を適用する（※ユーザー指示によりフォント変更はスキップし、カラー変数のみ定義）
  - [x] `app/assets/stylesheets/header_footer.css` でヘッダーに本棚風のボーダーを追加し、背景色などを Forest Nook テーマに合わせる
  - [x] `.btn` クラスにホバー時のマイクロアニメーションを導入し、`.btn--secondary` などの必要なクラスを追加する
- [x] ルーティングとナビゲーションの追加
  - [x] `config/routes.rb` に `resource :dashboard, only: [ :show ]` を追加する
  - [x] `app/views/shared/_header.html.erb` のユーザーメニューに「ダッシュボード」へのリンクを追加する
  - [x] `app/controllers/users/sessions_controller.rb` で `after_sign_in_path_for` メソッドの戻り値を `dashboard_path` に設定する

## フェーズ2: コントローラーとビューの実装

- [x] `DashboardsController` の作成
  - [x] `app/controllers/dashboards_controller.rb` を新規作成する
  - [x] `@reading_books` (進行中の本), `@total_daily_quota` (今日の総ノルマ) を取得する
  - [x] `@recent_completed_books` (最近読了した本、最大3冊) を取得する
  - [x] `@total_books_read`, `@total_pages_read` (統計データ) を取得する
  - [x] 読書記録 (`ReadingLog`) を基準としたストリーク計算ロジック `@streak_days` を実装する
  - [x] 過去7日間の日別読了ページ数を集計するロジック `@weekly_activity` を実装する
- [x] ビューテンプレート `dashboards/show.html.erb` の作成
  - [x] `app/views/dashboards/show.html.erb` を新規作成する
  - [x] Welcomeヘッダー、進行中の本、統計カード、週次アクティビティグラフ、最近読了した本を表示するマークアップを作成する
- [x] スタイルシート `dashboards.css` の作成
  - [x] `app/assets/stylesheets/dashboards.css` を新規作成する
  - [x] ダッシュボード全体のグリッドレイアウト、統計カード、アクティビティ棒グラフのスタイリングを定義する

## フェーズ3: 品質チェックとテストの実装

- [x] テストコードの実装
  - [x] `spec/requests/dashboards_spec.rb` を作成し、ダッシュボード画面へのアクセス制限や集計ロジックの動作検証を行う
  - [x] `spec/system/dashboards_spec.rb` を作成し、各セクションの表示確認を行う
- [x] テストの実行と修正
  - [x] `bundle exec rspec` ですべてのテストがパスすることを確認する
- [x] リントエラーがないことを確認
  - [x] `bundle exec rubocop` でコードスタイルに問題がないことを確認し、必要に応じて自動修正または手動修正を行う

## フェーズ4: ドキュメント更新と完了処理

- [x] 実装後の振り返り（このファイルの下部に記録）

---

## 実装後の振り返り

### 実装完了日
2026-06-07

### 計画と実績の差分

**計画と異なった点**:
- なし

**新たに必要になったタスク**:
- ログイン・登録後に `dashboard_path` へリダイレクトするよう仕様変更したため、既存のログイン、新規登録、パスワードリセットなどに関連するテスト（5ファイル）のリダイレクト先期待値を `books_path` から `dashboard_path` に修正するタスクが発生した。

**技術的理由でスキップしたタスク**（該当する場合のみ）:
- Google Fontsの読み込み、およびタイポグラフィ（font-serif）の見出し等への適用タスク（ユーザーからの明示的な指示により、フォントは変更せず現状のデザインを維持するためスキップ）。

### 学んだこと

**技術的な学び**:
- Deviseのログイン・サインアップ後のリダイレクト先変更に伴うテストコード全体の整合性の維持。

**プロセス上の改善点**:
- 仕様変更に伴い既存テストで影響を受ける範囲をあらかじめ洗い出すことで、開発効率が向上する。

### 次回への改善提案
- 特になし
