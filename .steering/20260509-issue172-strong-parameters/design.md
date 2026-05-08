# Issue #172 Design

## 実装アプローチ

### 1. 対象ファイルの特定
- `app/controllers/users/email_changes_controller.rb`

### 2. 変更内容
- `params` からの直接参照を削除
- Strong Parameters メソッドを使用して安全にパラメータを取得
- 既存の Devise バリデーションとの動作検証

### 3. Strong Parameters の実装パターン

```ruby
def update
  email_change_params = params.permit(:current_password, :email)
  current_password = email_change_params[:current_password]
  new_email = email_change_params[:email]
  # ... 既存のロジックは変更なし
end
```

または、プライベートメソッドを使用:

```ruby
private

def email_change_params
  params.permit(:current_password, :email)
end
```

### 4. 検証項目
- RuboCop チェック通過
- 既存テスト全通過
- 機能動作の確認
