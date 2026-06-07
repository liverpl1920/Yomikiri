# 設計書 (Issue #324)

## 設計概要
過去の読了本振り返りカード (`.lookback-card`) に書影コンポーネントを追加し、Flexboxを用いてPC・モバイルで適切なレイアウトを表現する。

## 修正対象

### 1. ビュー: `app/views/dashboards/_random_lookback.html.erb`
- `lookback-card__header` の下に `lookback-card__body` というラッパーを導入する。
- 左側に `lookback-card__cover-wrapper` を配置し、`book_cover_src(random_book)` でURLが取得できれば `image_tag` で画像を表示し、なければプレースホルダーを表示する。
- 右側に `lookback-card__details` を配置し、既存の書籍情報（タイトル、著者）、評価・感想、メモのセクションをそのままその中に包み込む。

### 2. スタイルシート: `app/assets/stylesheets/dashboards.css`
- `lookback-card__body`: `display: flex; gap: var(--spacing-md); align-items: flex-start;`
- `lookback-card__cover-wrapper`: 横幅 `100px`、アスペクト比 `3 / 4`、角丸や影を設定する。
- `lookback-card__cover-image`: `width: 100%; height: 100%; object-fit: cover;`
- `lookback-card__cover-placeholder`: `No Image` テキストと本のアイコン 📖 を中央表示する。
- `lookback-card__details`: `flex: 1; min-width: 0;`
- レスポンシブ対応 (`@media (max-width: 540px)`):
  - `lookback-card__body`: `flex-direction: column; align-items: center; text-align: center;`（もしくは詳細は左寄せに保つ。既存の `dashboard__book-card` のレスポンシブ挙動を参考にする）
  - モバイル時は書影を中央に配置する。

### 3. テスト: `spec/system/dashboards_spec.rb`
- 「過去の振り返り（ランダム振り返り）セクションが表示され、シャッフル動作が機能すること」のテストケースを拡張、または新しいケースを追加し、書影画像またはプレースホルダーが正しく表示されていることを検証する。
