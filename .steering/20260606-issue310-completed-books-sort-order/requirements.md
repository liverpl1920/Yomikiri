# Issue #310 要件

## 概要

読了した本の一覧において、並び順を「評価（星の数）順」から
「読了日（`completed_at`）の新しい順（降順）」に変更する。

## 期待される挙動

- 読了した本の一覧画面において、直近で読了した本が一番上に表示される。
- 過去に読了した本（読了日が古い本）ほど、一覧の下方に並ぶ。

## 現状分析

### 読了本の並び順を決めている箇所

`app/models/book.rb` の `for_index_list` スコープ（L61-L66）:

```ruby
scope :for_index_list, lambda {
  completed_val = statuses[:completed]
  status_col = arel_table[:status]
  ordering = Arel::Nodes::Case.new.when(status_col.eq(completed_val)).then(1).else(0)
  order(ordering, :deadline)  # ← 読了本の二次ソートが :deadline になっている
}
```

1次ソート: 未了本(0) → 読了本(1)  
2次ソート: `deadline` 昇順（すべての本に適用）

Issue #310 では、読了本グループの2次ソートを `completed_at: :desc` に変更する。

## 変更対象

- `app/models/book.rb`: `for_index_list` スコープのソート順修正
- `spec/models/book_spec.rb`: 既存の `'読了済みの本が複数ある場合も期限順に並ぶ'` テストを更新
