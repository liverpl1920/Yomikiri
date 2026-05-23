# タスクリスト: 読了済み書籍編集時の読了期限バリデーション除外 (#219)

## フェーズ1: モデル修正

- [x] `app/models/book.rb` の `deadline_cannot_be_in_the_past` バリデーション条件に `!completed?` を追加

## フェーズ2: ビュー修正

- [x] `app/views/books/_form.html.erb` の deadline フィールドの `min` 属性を読了済み書籍の場合は `nil` に変更

## フェーズ3: テスト追加

- [x] `spec/models/book_spec.rb` に「読了済み書籍の編集時は過去日の期限が有効」テストを追加
- [x] `spec/models/book_spec.rb` に「未読書籍の編集時は過去日の期限が無効」テストの確認
- [x] `spec/requests/books_spec.rb` に読了済み書籍の編集で過去日期限が保存できることを確認するテストを追加

## フェーズ4: 検証

- [x] RSpec を実行して全テスト通過を確認
- [x] RuboCop を実行してコーディング規約違反がないことを確認（ERBファイルはRuby構文パーサーの制限により除外）

---

## 振り返り（完了後に記載）

**実装完了日:** 2026-05-24

### 計画と実績の差分
- 計画通りに実装完了。変更ファイルは3つ（model, view, spec）で想定内。

### 実装内容
- `app/models/book.rb`: `deadline_cannot_be_in_the_past` バリデーション条件に `!completed?` を追加
- `app/views/books/_form.html.erb`: deadline フィールドの `min` 属性を `book.completed?` の場合は `nil` に変更
- `spec/models/book_spec.rb`: 読了済み・未読書籍の deadline バリデーションテストを追加
- `spec/requests/books_spec.rb`: 読了済み書籍の編集で過去日期限が保存できるリクエストテストを追加

### 学んだこと
- バリデーション条件の `if:` ラムダに `!completed?` を追加するだけで、モデルのインメモリ状態を参照するため正確に動作する
- `apply_past_reading_settings` は `before_save` で動作するため、バリデーション時点のステータスに影響しない。新規作成+is_past_reading=true のフローでは別途考慮が必要

### 次回への改善提案
- 新規作成時の `is_past_reading=true` フローでも deadline の過去日バリデーションが走るが、現時点では別 Issue として対応を検討
