# 設計書

## アーキテクチャ概要

Rails MVC の View 層変更を中心とした小規模改修とし、`books#index` の表示条件を明確化する。
既存の `Book` モデル属性（`status`, `rating`）を利用し、新規DB変更やサービス追加は行わない。

```mermaid
flowchart TD
	A[BooksController#index] --> B[@books を取得]
	B --> C[books/index.html.erb で各 book を描画]
	C --> D{book.completed? && book.rating.present?}
	D -- Yes --> E[評価ラベル + ★を rating 個表示]
	D -- No --> F[評価欄を非表示]
```

## コンポーネント設計

### 1. `app/views/books/index.html.erb`

責務:
- 一覧カードの表示ロジックを維持しつつ、読了本評価を条件付き表示する。
- 未読/読書中・評価未設定時には評価欄を描画しない。

実装の要点:
- 既存カード本文の情報構成を壊さない位置に評価欄を追加する。
- 表示は `book.completed? && book.rating.present?` を条件にする。
- 星表示は `"★" * book.rating` とし、既存仕様に合わせる。

### 2. Request spec（`spec/requests/books_spec.rb` など）

責務:
- 一覧HTMLに対して評価表示条件が満たされていることを検証する。

実装の要点:
- 読了済み評価ありで表示されること。
- 読了済み評価なし、未読/読書中で表示されないこと。
- 既存仕様の主要期待値を壊さないこと。

## データフロー

### 一覧表示時の評価描画
1. `BooksController#index` が `@books` を設定して `index` ビューを描画する。
2. ビューが各 `book` をループし、`book.completed? && book.rating.present?` を判定する。
3. 条件が真なら評価欄に `★` を `rating` 分描画、偽なら評価欄を描画しない。

## エラーハンドリング戦略

### カスタムエラークラス
今回の変更では不要。

### エラーハンドリングパターン
- `rating` が `nil` の場合は表示しないだけで例外を発生させない。
- 既存モデルバリデーション（`rating` は1-5の整数またはnil）を前提とする。

## テスト戦略

### ユニットテスト
- モデルロジック追加なしのため新規Unit testは不要。

### 統合テスト
- Request spec で HTML 出力を検証。
- 必要に応じて System spec で画面表示確認を追加。

## 依存ライブラリ

新規追加なし。

## ディレクトリ構造

```
app/views/books/index.html.erb             # 一覧カードの評価表示を追加
spec/requests/books_spec.rb                # 一覧表示条件のテスト追加/更新
.steering/20260527-issue241-completed-rating-on-index/
	requirements.md
	design.md
	tasklist.md
```

## 実装の順序

1. 一覧ビューに評価表示ロジックを追加。
2. Request spec を追加/更新して表示条件を担保。
3. RSpec と RuboCop を実行して回帰を確認。

## セキュリティ考慮事項

- 表示するのは `rating` 数値に基づく固定文字（`★`）のみで、ユーザー入力文字列を直接挿入しない。

## パフォーマンス考慮事項

- 追加処理は単純な条件分岐と短い文字列演算のみで、一覧性能への影響は軽微。

## 将来の拡張性

- 評価表示をヘルパー化することで、将来の星表示デザイン変更（塗り/枠、最大値変更）に対応しやすくできる。
