# タスクリスト: 一覧画面の読書状態表示修正（#224）

## フェーズ1: モデル修正

- [x] T1: `auto_set_reading_status` から `return unless persisted?` を削除
- [x] T2: `will_transition_to_reading?` から `persisted? &&` を削除

## フェーズ2: ビュー修正

- [x] T3: `_form.html.erb` の `deadline_optional_for_form` 条件を修正（new_record? → new_record? && current_page.to_i.zero?）

## フェーズ3: スペック修正・追加

- [x] T4: `'新規作成では current_page が 0 以外でもステータスを自動変更しない'` スペックを挙動反転に修正
- [x] T5: 新規作成時 current_page > 0 で deadline 必須のスペックを追加
- [x] T6: 新規作成時 current_page = 0 は依然 unread のままのスペックを確認

## フェーズ4: 検証

- [x] T7: bundle exec rspec spec/models/book_spec.rb で全通過確認（113 examples, 0 failures）
- [x] T8: bundle exec rubocop app/models/book.rb spec/models/book_spec.rb で通過確認（no offenses）

---

## 振り返り

### 実装完了日
2026-05-24

### 計画と実績の差分
- 計画通り `auto_set_reading_status` と `will_transition_to_reading?` の `persisted?` ガードを除去し、新規作成時にも遷移が発火するようにした
- CI で `spec/requests/books_spec.rb` の期待値ズレが1件発覚 → `current_page: 100` で作成した本が `reading` になることに伴い期待値を修正
- Copilot レビューで `deadline_optional_for_form` の表示不整合を指摘 → `|| book.unread?` が新規作成+current_page > 0 の場合に「任意」表示のままになる問題を修正

### 学んだこと
- `before_save` コールバックはバリデーション後に動作するため、バリデーションと `before_save` で想定するステータス状態の整合性を必ず確認すること
- ビュー側の「任意/必須」表示ロジックはモデルの `deadline_optional?` と常に対応させる必要がある。分離すると不整合が生じやすい

### 次回への改善提案
- ビューの `deadline_optional_for_form` ロジックはモデルの public メソッドとして公開するか、helper に切り出すと重複がなくなる
- CI の全スペック実行をローカルでも実施してから push する（今回は model spec のみで通過確認したため requests spec の修正漏れが発生した）
