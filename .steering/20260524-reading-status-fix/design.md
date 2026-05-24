# 設計: 一覧画面の読書状態表示修正（#224）

## 原因分析

`Book#auto_set_reading_status` メソッドに `return unless persisted?` のガードがあるため、新規作成時（`persisted? = false`）は `current_page > 0` でも `status: unread` のまま保存される。

```ruby
def auto_set_reading_status
  return unless unread?
  return unless persisted?   # ← NEW レコードで early return
  return unless current_page_changed?
  return unless current_page_was.to_i.zero?
  return if current_page.to_i.zero?

  self.status = :reading
end
```

同様に `will_transition_to_reading?` でも `persisted?` チェックがあり、新規作成時に deadline が required になるべきケースで optional のまま通過してしまう。

## 変更方針

### 変更1: `app/models/book.rb`

**`auto_set_reading_status`**:
- `return unless persisted?` を削除
- 新規作成時でも `current_page > 0` なら `status = :reading` へ遷移

**`will_transition_to_reading?`**:
- `persisted? &&` 条件を削除
- 新規作成時でも正しく遷移判定され、deadline バリデーションが発火する

### 変更2: `app/views/books/_form.html.erb`

**`deadline_optional_for_form`** の条件を修正:
```erb
<%# 旧: book.new_record? は常に true → deadline 常に任意表示 %>
<% deadline_optional_for_form = book.new_record? || book.unread? || book.completed? %>

<%# 新: 新規作成かつ current_page = 0 の場合のみ任意 %>
<% deadline_optional_for_form = (book.new_record? && book.current_page.to_i.zero?) || book.unread? || book.completed? %>
```

### 変更3: `spec/models/book_spec.rb`

- `'新規作成では current_page が 0 以外でもステータスを自動変更しない'` → 挙動反転: reading になる
- deadline バリデーション: 新規作成時 current_page > 0 でも deadline 必須のスペックを追加

## 影響範囲

| ファイル | 変更種別 |
|---------|---------|
| `app/models/book.rb` | ロジック修正（2メソッド） |
| `app/views/books/_form.html.erb` | 表示条件修正（1行） |
| `spec/models/book_spec.rb` | スペック修正・追加 |
