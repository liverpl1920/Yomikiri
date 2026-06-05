# Yomikiri UI 刷新 & ダッシュボード実装 TODOリスト

「Forest Nook (森の書斎)」デザインテーマおよびダッシュボード機能を完全に実装するために必要な具体的な変更点の一覧です。

---

## 🛠️ 1. 基本設定とタイポグラフィ

- [ ] **Google Fonts の読み込み**
  - ファイル: `app/views/layouts/application.html.erb`
  - 変更点: `<head>` 内に以下のフォント読み込みタグを追加する。
    ```html
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Serif+JP:wght@400;700&family=Outfit:wght@400;600;700&display=swap" rel="stylesheet">
    ```

---

## 🎨 2. 共通スタイル・変数の定義

- [ ] **CSS変数の更新**
  - ファイル: `app/assets/stylesheets/application.css`
  - 変更点: `:root` 内のカラー変数とタイポグラフィ変数を以下のように更新する。
    ```css
    :root {
      /* カラーパレット */
      --color-primary: #1B4332;          /* 深い森の緑 */
      --color-primary-hover: #2D6A4F;    /* 明るめの深緑 */
      --color-secondary: #8C5E3C;        /* ウッドブラウン */
      --color-secondary-hover: #734C2F;  /* 濃いウッドブラウン */
      --color-text: #2E251B;             /* 焦げ茶 */
      --color-text-muted: #6D6257;       /* 樹皮ベージュ */
      --color-bg: #FAF8F5;               /* 紙の白 */
      --color-bg-surface: #F3EFE9;       /* 薄いウッドベージュ */
      --color-border: #E3DDD3;           /* 優しいベージュ */
      --color-danger: #A63A50;           /* くすんだ赤 */
      --color-danger-hover: #8F2A3E;     /* 濃いエンジ */
      --color-success: #40916C;          /* リーフグリーン */

      /* タイポグラフィ */
      --font-sans: "Outfit", "Noto Sans JP", sans-serif;
      --font-serif: "Noto Serif JP", serif;

      /* レイアウト調整 (丸みを大きく) */
      --border-radius: 0.75rem;
      --border-radius-lg: 1rem;

      /* シャドウ調整 */
      --shadow-sm: 0 1px 3px rgba(46, 37, 27, 0.05);
      --shadow-md: 0 4px 12px rgba(46, 37, 27, 0.08);
      --shadow-lg: 0 12px 30px rgba(46, 37, 27, 0.12);
    }
    ```

- [ ] **見出しフォントの適用**
  - ファイル: `app/assets/stylesheets/application.css`
  - 変更点: `h1, h2, h3, h4, h5, h6` に `font-family: var(--font-serif);` を適用する。

- [ ] **共通ボタン・コンポーネントスタイルの刷新**
  - ファイル: `app/assets/stylesheets/application.css`
  - 変更点:
    - `.btn` クラスに `transform 0.2s, box-shadow 0.2s` の遷移を追加し、ホバー時に少し浮き上がるマイクロアニメーションを導入。
    - `.btn--secondary` を追加（背景を `--color-bg-surface`、ボーダーを `--color-border`）。
    - `.btn--danger:hover` 等のカラーを更新した変数と紐づける。

---

## 🏛️ 3. ナビゲーションとフッター

- [ ] **ヘッダーに本棚風のボーダーを追加**
  - ファイル: `app/assets/stylesheets/header_footer.css`
  - 変更点:
    - `.site-header` の背景色を `var(--color-bg-surface)` にし、下部に `2px solid var(--color-secondary)` のボーダーを追加する（棚板を連想させる境界線）。
    - `.site-header__logo` に `font-family: var(--font-serif);` を適用する。
- [ ] **ナビゲーションリンクの追加**
  - ファイル: `app/views/shared/_header.html.erb`
  - 変更点: ログイン中ユーザー用に「ダッシュボード」と「積読一覧」へのナビゲーションリンクを追加。
    ```html
    <% if user_signed_in? %>
      <nav class="site-header__nav" aria-label="メインナビゲーション">
        <%= link_to 'ダッシュボード', dashboard_path, class: 'site-header__nav-link' %>
        <%= link_to '積読一覧', books_path, class: 'site-header__nav-link' %>
    ```
- [ ] **フラッシュメッセージのカラー調整**
  - ファイル: `app/assets/stylesheets/header_footer.css`
  - 変更点: `.flash--notice`, `.flash--alert` の配色を新しいテーマカラー（穏やかなグリーンとエンジ）に調和するように調整する。

---

## 📚 4. 本棚一覧および詳細画面のスタイル

- [ ] **書籍カードのビジュアル刷新**
  - ファイル: `app/assets/stylesheets/books.css`
  - 変更点:
    - `.book-card` の背景を `var(--color-bg-surface)` にし、ホバー時に `transform: translateY(-4px)` と影（`--shadow-md`）が強まるマイクロアニメーションを適用する。
    - `.book-card__progress-bar` の背景色を `var(--color-success)` (リーフグリーン) にし、角丸にする。

- [ ] **「今日のノルマ」の木製プレート風あしらい**
  - ファイル: `app/assets/stylesheets/books.css`
  - 変更点: 
    - `.book-card__quota` または詳細画面のノルマ表示エリアを、`border: 2px solid var(--color-secondary);` と `background-color: var(--color-bg);` を用いて木製プレートのように装飾する。

- [ ] **賞味期限ビジュアライザーの古書化調整**
  - ファイル: `app/assets/stylesheets/books.css`
  - 変更点: 期限が近い本の画像エフェクトを、深みのある温かいアンティークトーン（セピアとコントラストの組み合わせ）に調整する。

---

## 📊 5. ダッシュボード画面の新設

- [ ] **ルーティングの追加**
  - ファイル: `config/routes.rb`
  - 変更点: `dashboard` リソースを追加。
    ```ruby
    resource :dashboard, only: [ :show ]
    ```

- [ ] **ログイン後のリダイレクト先変更**
  - ファイル: `app/controllers/users/sessions_controller.rb` (または `ApplicationController` に定義がある場合)
  - 変更点: `after_sign_in_path_for` メソッドの戻り値を `dashboard_path` に設定。
    ```ruby
    def after_sign_in_path_for(resource)
      dashboard_path
    end
    ```

- [ ] **ダッシュボードコントローラーの作成**
  - ファイル: [NEW] `app/controllers/dashboards_controller.rb`
  - 変更点: 以下のデータを取得し、インスタンス変数に格納する。
    - 読書中の書籍リスト (`@reading_books`)
    - 最近読了した書籍リスト (`@recent_completed_books`)
    - 今日の総読書ノルマ (`@total_daily_quota`)
    - 総読了ページ数・総読了冊数（統計データ）
    - 連続読書日数 (ストリーク) の計算ロジック
    ```ruby
    class DashboardsController < ApplicationController
      before_action :authenticate_user!

      def show
        # 進行中の書籍
        @reading_books = current_user.books.where(status: :reading).order(deadline: :asc)
        @total_daily_quota = @reading_books.sum(&:daily_quota)

        # 最近読了した本
        @recent_completed_books = current_user.books.where(status: :completed).order(completed_at: :desc).limit(3)

        # 読書統計
        @total_books_read = current_user.books.where(status: :completed).count
        @total_pages_read = ReadingLog.joins(:book).where(books: { user_id: current_user.id }).sum(:pages_read)

        # 読書ストリーク計算 (昨日のログ、または今日のログがあればカウント)
        @streak_days = calculate_reading_streak

        # 週次アクティビティ (過去7日間の日別読了ページ数)
        @weekly_activity = calculate_weekly_activity
      end

      private

      def calculate_reading_streak
        # 読書ストリーク（連続日数）を計算するロジック
        dates = ReadingLog.joins(:book)
                          .where(books: { user_id: current_user.id })
                          .order(read_at: :desc)
                          .pluck(:read_at)
                          .uniq
        return 0 if dates.empty?

        streak = 0
        current_date = Date.current

        # 今日、または昨日から連続しているかを検証
        if dates.first == current_date || dates.first == current_date - 1.day
          dates.each do |date|
            if date == current_date - streak.days || date == (current_date - 1.day) - streak.days
              streak += 1
            else
              break
            end
          end
        end
        streak
      end

      def calculate_weekly_activity
        # 過去7日間の日別ページ数を集計してハッシュにする
        start_date = Date.current - 6.days
        logs = ReadingLog.joins(:book)
                          .where(books: { user_id: current_user.id })
                          .where(read_at: start_date..Date.current)
                          .group(:read_at)
                          .sum(:pages_read)
        (start_date..Date.current).map { |date| [date.strftime("%a"), logs[date] || 0] }.to_h
      end
    end
    ```

- [ ] **ダッシュボードビューの作成**
  - ファイル: [NEW] `app/views/dashboards/show.html.erb`
  - 変更点: モックデザインを完全に再現するHTML構造を作成する。
    - **Welcome ヘッダー**: ユーザー名と日付の表示。
    - **Current Reads（現在進行中の本）**: 各カードに書籍の表紙、タイトル、著者名、進捗率（%）、進捗更新ボタンを配置。
    - **Reading Stats（統計カード）**: 総読書ページ数、読了冊数、現在のストリーク日数を表示する3つのミニグリッド。
    - **Reading Goal（今年の目標）**: 目標冊数（例: 24/50冊）と進捗バーを表示するエリア。
    - **Reading Activity (週次グラフ)**: CSSでスタイリングした棒グラフを表示するセクション（`@weekly_activity` のデータを使用）。
    - **Recently Finished（最近読了した本）**: 書影と評価（★星）のリスト。

- [ ] **ダッシュボードスタイルシートの作成**
  - ファイル: [NEW] `app/assets/stylesheets/dashboards.css`
  - 変更点: Forest Nook の配色を活用し、レスポンシブなグリッド・フレックスボックスのレイアウトを作成。
    - ダッシュボード全体のグリッドレイアウト（`.dashboard-grid`）。
    - 統計情報エリアのカードデザイン。
    - 棒グラフ (`.activity-chart`) を表現するCSSバー。

---

## 📝 6. その他の画面（ログイン・マイページ）

- [ ] **認証画面・フォーム入力欄の更新**
  - ファイル: `app/assets/stylesheets/auth.css`
  - 変更点: サインイン・サインアップ画面のカードや入力フォームの境界線、角丸を新しい変数に調和させる。
- [ ] **マイページ一覧の更新**
  - ファイル: `app/assets/stylesheets/mypages.css`
  - 変更点: マイページ画面のタブメニューやプロフィールカードのデザインをアースカラーで統一する。

---

## 🧪 7. 検証と品質チェック

- [ ] **テストの実行**
  - コマンド: `bundle exec rspec`
  - 目的: 新設したダッシュボードの機能・システムテストを追加して実行し、他の既存のテストが崩れていないか確認する。
- [ ] **コードスタイルの確認**
  - コマンド: `bundle exec rubocop`
  - 目的: 静的解析で違反がないことを確認する。
