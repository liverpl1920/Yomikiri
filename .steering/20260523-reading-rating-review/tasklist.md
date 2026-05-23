# タスクリスト: 読了完了画面で評価・感想入力を追加 (ISSUE#197)

## フェーズ1: DB・モデル

- [x] マイグレーションファイル作成（rating, review カラム追加）
- [x] マイグレーション実行
- [x] Book モデルにバリデーション追加（rating: 1〜5, review: 最大1000文字）

## フェーズ2: コントローラー・ルーティング

- [x] routes.rb に update_review ルートを追加
- [x] BooksController に update_review アクション追加
- [x] Strong Parameters (review_params) 追加

## フェーズ3: ビュー

- [x] show.html.erb に評価・感想セクション追加（読了済み時のみ表示）
- [x] 評価（★ラジオボタン1〜5）UIの実装
- [x] 感想テキストエリアUIの実装
- [x] books.css にスタイル追加

## フェーズ4: テスト

- [x] spec/models/book_spec.rb に rating バリデーションテスト追加
- [x] spec/requests/books_spec.rb に update_review テスト追加

## フェーズ5: 検証

- [x] bundle exec rspec 全通過確認
- [x] bundle exec rubocop エラーなし確認

---

## 振り返り（完了後に記載）

### 実装完了日
2026-05-23

### 計画と実績の差分
- 計画通りに全タスクを完了
- implementation-validator の推奨に従い、XSSエスケープテストとフラッシュメッセージテストをスペックに追加（計画外の改善）

### 学んだこと
- ★ラジオボタンのCSSでは `flex-direction: row-reverse` を使うと右から左への順序（大→小）を直感的に逆転でき、CSSの `:has()` セレクタでホバーと選択状態のスター色を制御できる
- `review_params` を `memo_params` と別に定義することで Strong Parameters の責務分離が明確になる

### 次回への改善提案
- `.sr-only` クラスは共通CSSへ移動するとよい（他画面でも再利用可能）
- スター色（`#f6ad55`）をCSS変数化するとデザイントークンの一貫性が向上する
