# 設計: ISSUE#226, #227 読了期限の任意化

## 実装方針

### モデル設計

#### deadline バリデーション条件の変更

```ruby
# 変更前
validates :deadline, presence: true

# 変更後
validates :deadline, presence: true, unless: :deadline_optional?
```

#### deadline_optional? メソッド

```ruby
def deadline_optional?
  past_reading_checked? ||
    (unread? && !will_transition_to_reading?) ||
    completed?
end
```

- `past_reading_checked?`: is_past_reading フラグ（Issue#226）
- `unread? && !will_transition_to_reading?`: 積読状態かつ unread→reading 遷移しない（Issue#227）
- `completed?`: 読了済み書籍の編集時に nil deadline を許容（過去読書書籍の再編集）

#### will_transition_to_reading? メソッド

```ruby
def will_transition_to_reading?
  unread? && persisted? &&
    current_page_changed? &&
    current_page_was.to_i.zero? &&
    current_page.to_i > 0
end
```

auto_set_reading_status コールバックと同じ条件を検証時にチェック。

#### nil 安全化が必要なメソッド

| メソッド | 変更内容 |
|---------|---------|
| `days_remaining` | `return nil if deadline.nil?` を追加 |
| `overdue?` | `return false if deadline.nil?` を追加 |
| `deadline_urgency_class` | `return "" if completed? \|\| deadline.nil?` に変更 |
| `daily_quota` | `return 0 if completed? \|\| deadline.nil?` に変更 |
| `extend_deadline!` | `deadline.nil?` 時の比較保護を追加 |

### ビュー設計

#### _form.html.erb

- deadline ラベルを条件分岐: 新規 or unread or completed → 「任意」、reading → 「必須」

```erb
<% deadline_optional_for_form = book.new_record? || book.unread? || book.completed? %>
```

#### show.html.erb

1. **読了期限表示セクション**: nil の場合は「未設定」を表示
2. **進捗更新フォーム**: unread && deadline.nil? の場合は非表示にし、設定案内を表示
3. **読了ボタン**: unread && deadline.nil? の場合は非表示
4. **期限延長ボタン/モーダル**: deadline.nil? の場合は非表示
5. **今日のノルマ表示**: deadline.nil? の場合は「-」を表示

#### index.html.erb

- `l(book.deadline, format: :long)` の nil ガード: nil の場合は「未設定」を表示

### スペック設計

#### 更新が必要なテスト

- `'読了期限がない場合は無効'` → `unread` ステータスでは nil でも有効に変更

#### 追加するテスト

- 積読書籍は読了期限なしで有効
- 積読書籍の読書中遷移（initial progress）では読了期限が必須
- 過去読書（is_past_reading）では読了期限なしで有効
- 読書中書籍は読了期限なしで無効
- 読了済み書籍は読了期限なしで有効（編集ケース対応）
