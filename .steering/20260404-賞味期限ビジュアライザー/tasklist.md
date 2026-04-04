# タスクリスト: 賞味期限ビジュアライザー機能 (Issue #23)

## フェーズ1: ブランチ作成

- [x] feature/#23-deadline-visualizer ブランチを作成

## フェーズ2: W-6 詳細画面の実装

- [x] show.html.erb に書影エリアと urgency class / バッジを追加
- [x] books.css に show ページ用の書影・バッジスタイルを追加

## フェーズ3: テスト追加

- [x] books_spec.rb に urgency 関連のリクエストスペックを追加

## フェーズ4: 検証

- [x] bundle exec rspec を実行して全テストグリーン確認
- [x] bundle exec rubocop でエラーなし確認

---

## 実装後の振り返り

**実装完了日**: 2026-04-04

### 計画と実績の差分

- 計画通りに実装完了。ただし実装中に CSS の重複定義を発見・修正。
- W-4（index）は既に実装済みだったため、実際の実装対象は W-6（show）のみだった。

### 学んだこと

- 既存コードに部分的な実装が残っていることがあるため、実装前の調査が重要。
- CSS を追加する際は同一セレクターの重複定義が起きないよう既存ファイルを確認してから挿入位置を決める。
- `deadline_urgency_class` は `book-card__cover--urgent-*` という book-card ブロックのクラスを返すため、show ページで使う場合に BEM の観点で若干の混在が生じる（機能上は問題なし）。

### 次回への改善提案

- `deadline_urgency_class` の戻り値から `book-card__cover--` プレフィックスを除去してブロック非依存のクラス名（例: `urgency-low`）を返し、各ページ側でブロックを prefix するパターンも検討値あり。
- urgency バッジに `role="status"` を付与してスクリーンリーダー対応を強化する（本 Issue 範囲外だが今後考慮）。

