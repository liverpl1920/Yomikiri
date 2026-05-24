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
（全タスク完了後に記載）
