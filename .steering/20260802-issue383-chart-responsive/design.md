# 設計書

## アーキテクチャ概要

本機能は、書籍詳細画面（`app/views/books/show.html.erb`）の進捗グラフ（SVG）の描画ロジックの改善およびCSSによるレスポンシブスタイリングの調整です。

## コンポーネント設計

### 1. ビューテンプレート (`app/views/books/show.html.erb`)

**責務**:
- 進捗グラフ（SVG）の描画。
- 日付ラベルの自動間引き。

**実装の要点**:
- `chart_width` をデータ点数依存（`[chart_rows.size * 28, 520].max`）から固定値（`520`）に変更し、SVGの `viewBox` アスペクト比を固定（`520:220`）にします。
- 日付ラベルの間引きロジックを実装します。データ点数（`chart_rows.size`）に応じて間引きのステップ数 `step` を以下のように決定します：
  - `size <= 10`: `step = 1`（毎日）
  - `size <= 20`: `step = 2`（2日ごと）
  - `size <= 40`: `step = 5`（5日ごと）
  - `size <= 80`: `step = 7`（1週間ごと）
  - その他: `step = 14`（2週間ごと）
- `x_label_indexes` の配列を生成する際、インデックス `0`（最初）と `chart_rows.size - 1`（最後）を必ず含めるようにし、最後のラベルが直前のラベルと重ならないように調整します。

### 2. スタイルシート (`app/assets/stylesheets/books.css`)

**責務**:
- グラフコンテナの横スクロール制御と、SVGのレスポンシブ縮小。

**実装の要点**:
- スマホ表示用のメディアクエリ（`@media (max-width: 640px)`）の中に以下を追加します：
  - `.book-show__chart-scroll` に対し `overflow-x: hidden;` を指定し、横スクロールを発生させないようにします。
  - `.book-show__chart-svg` に対し `min-width: 0;` を指定し、親コンテナ幅に収まるよう自動伸縮（アスペクト比固定のまま縮小）させます。

## テスト戦略

### ユニットテスト / システムテスト
- 既存の `spec/system/books/books_crud_spec.rb` や `spec/requests/books_spec.rb` が正常に動作することを確認します。
- グラフに読書ログが表示される挙動に変更がないか確認します。
- 日付の間引きロジックが正しい配列を生成することを確認します。

## ディレクトリ構造

```
app/
  assets/
    stylesheets/
      books.css
  views/
    books/
      show.html.erb
```

## 実装の順序

1. `app/views/books/show.html.erb` にて `chart_width` を固定化し、日付ラベルの間引きロジックを追加。
2. `app/assets/stylesheets/books.css` のメディアクエリ（`max-width: 640px`）にレスポンシブ用の上書きスタイルを追加。
3. ローカルサーバーやテストで動作確認。
