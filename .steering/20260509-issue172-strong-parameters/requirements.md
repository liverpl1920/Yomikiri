# Issue #172 Requirements

## 概要

`app/controllers/users/email_changes_controller.rb` の `update` アクションが、Strong Parameters を経由せずに `params` を直接参照しています。

## 該当コード

```ruby
# app/controllers/users/email_changes_controller.rb
def update
  current_password = params[:current_password]  # Strong Parameters 未使用
  new_email = params[:email]                    # Strong Parameters 未使用
  ...
end
```

## 問題点

Rails の規約では、コントローラーでユーザー入力を扱う際は `params.require(...).permit(...)` による Strong Parameters を使用することが推奨されています。

- Rails セキュリティ規約（マスアサインメント防止）に違反している
- 将来コードが変更された際にマスアサインメント脆弱性を生みやすい
- RuboCop / Security audit ツールで指摘対象になる

## 対応方針

`params` からの値取得を Strong Parameters 形式に変更する

## 完了条件

1. `params` からの値取得が Strong Parameters 形式に変更されている
2. 既存の機能・テストが継続して動作する
3. RuboCop チェックを通過する
4. RSpec テストが全て通過する
