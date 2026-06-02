# タスクリスト: ISSUE#226 過去読書登録時の読了期限任意化

## フェーズ1: 調査
- [x] T1: ISSUE#226要件に対する既存実装の有無をモデル・ビュー・スペックで確認する

## フェーズ2: 実装
- [x] T2: 未達要件がある場合のみ、最小差分で実装を追加する（フォームのdeadline必須/任意表示条件に`is_past_reading`を反映）

## フェーズ3: 検証
- [x] T3: 関連RSpecを実行してISSUE#226の受け入れ条件を確認する
- [x] T4: implementation-validatorで変更妥当性を検証する

## フェーズ4: 振り返り
- [x] T5: tasklist.mdに実装完了日・差分・学び・改善提案を記載する

---

## 振り返り

**実装完了日**: 2026-05-31

**計画と実績の差分**:
- 当初は既存実装の確認のみで完了見込みだったが、implementation-validatorの指摘によりフォーム表示条件の不整合を追加修正した
- `app/views/books/_form.html.erb` の `deadline_optional_for_form` に `is_past_reading` 判定を追加し、モデルの `deadline_optional?` と整合させた

**学んだこと**:
- 受け入れ条件を満たしていても、モデル条件とUI表示条件のズレは運用上の誤解を生むため、検証フェーズでの差分確認が有効
- 既存Issue完了後の再実装依頼では「未実装の有無確認」だけでなく「整合性確認」まで含めると品質が安定する

**次回への改善提案**:
- モデル条件をビューで再実装する箇所は、ヘルパー化または明示コメントで同期ポイントを管理する
- Rackの `:unprocessable_entity` 非推奨警告がテストログに出ているため、別Issueで `:unprocessable_content` への移行を検討する

**実行結果**:
- `bundle exec rspec spec/models/book_spec.rb`: 120 examples, 0 failures
- `bundle exec rspec spec/models/book_spec.rb spec/requests/books_spec.rb`: 293 examples, 0 failures
- `bundle exec rubocop app/models/book.rb spec/models/book_spec.rb spec/requests/books_spec.rb`: 3 files, no offenses
