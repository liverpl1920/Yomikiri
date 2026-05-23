# 設計: 読了済み書籍編集時の読了期限バリデーション除外

## 変更対象ファイル

### 1. `app/models/book.rb`

#### 現在の実装
```ruby
validate :deadline_cannot_be_in_the_past, if: -> { new_record? || will_save_change_to_deadline? }
```

#### 変更後
```ruby
validate :deadline_cannot_be_in_the_past, if: -> { !completed? && (new_record? || will_save_change_to_deadline?) }
```

**理由:** `completed?` は現在のモデルの `status` 属性を参照する。既存の completed 書籍を編集する場合、更新時に status は変わらないため `completed? == true` となり、バリデーションがスキップされる。

### 2. `app/views/books/_form.html.erb`

#### 現在の実装
```erb
<%= f.date_field :deadline,
      min: Date.current.to_s,
      ...
```

#### 変更後
```erb
<%= f.date_field :deadline,
      min: (book.completed? ? nil : Date.current.to_s),
      ...
```

**理由:** HTML の `min` 属性によるクライアントサイド制約も、読了済み書籍では除外する。

### 3. `spec/models/book_spec.rb`

既存の `deadline` バリデーションテストに以下を追加:
- 読了済み書籍（status: completed）の編集時に過去日の期限を設定しても有効であること
- 未読・読書中書籍の編集時は従来通り無効であること

## 影響範囲
- `Book` モデルのバリデーションロジック（既存の動作は維持）
- 編集フォームの日付入力 `min` 属性（新規作成・未読・読書中書籍では変更なし）

## リスク・注意事項
- `apply_past_reading_settings` の `before_save` コールバックは validation の後に実行される。
  既存の「新規作成 + is_past_reading=true」フローは対象外のため影響なし。
- `completed?` チェックはモデルのインメモリ状態を参照するため、`status` が変更されていない更新においては正確に機能する。
