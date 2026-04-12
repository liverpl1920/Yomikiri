# 設計書

## アーキテクチャ概要

Rails 標準の MVC パターンを採用。`MypagesController` を新設し、`show`（表示）と `update`（ニックネーム更新）の2アクションを実装する。

```
Browser → GET /mypage   → MypagesController#show   → app/views/mypages/show.html.erb
Browser → PATCH /mypage → MypagesController#update → redirect to mypage (or re-render with errors)
```

## コンポーネント設計

### 1. MypagesController

**責務**:
- マイページ表示に必要なデータを収集
- ニックネーム更新の処理

**実装の要点**:
- `authenticate_user!` で認証必須
- `show` アクション: 読書実績の計算ロジックはモデルに委譲
- `update` アクション: `current_user.update(nickname: params[:user][:nickname])`
- 更新成功時は `mypage_path` へリダイレクト（フラッシュ付き）
- 更新失敗時は `show` を再レンダリング

### 2. User モデル追加メソッド

**責務**:
- 読書実績の計算

**実装の要点**:
- `completed_books_count`: `books.completed.count`
- `completed_pages_total`: `books.completed.sum(:target_pages)`
- `consecutive_reading_days`: `books.updated_at` の日付を集計し連続読書日数を計算

連続読書日数アルゴリズム:
```ruby
def consecutive_reading_days
  dates = books.pluck(:updated_at).map(&:to_date).uniq.sort.reverse
  return 0 if dates.empty?

  streak = 0
  check_date = dates.include?(Date.current) ? Date.current : Date.current - 1.day
  dates.each do |date|
    if date == check_date
      streak += 1
      check_date -= 1.day
    end
  end
  streak
end
```

### 3. Routes

```ruby
resource :mypage, only: [:show, :update]
```
→ `GET /mypage` → show, `PATCH /mypage` → update  
→ `mypage_path` ヘルパーが生成される

### 4. View (app/views/mypages/show.html.erb)

**セクション構成**:
1. ユーザー情報カード（ニックネーム・メール・登録日）
2. ニックネーム編集フォーム（インライン）
3. 読書実績カード（読了冊数・総ページ・連続読書日数）
4. 読了履歴テーブル（completed_at 降順）
5. アカウント設定リンク（パスワード変更）
6. 「一覧に戻る」ボタン

### 5. CSS (app/assets/stylesheets/mypages.css)

BEM 命名規則に従い `.mypage-*` プレフィックスで定義。

### 6. ヘッダー更新

`app/views/shared/_header.html.erb` の `edit_user_registration_path` を `mypage_path` に変更。

## データフロー

### マイページ表示
```
1. GET /mypage リクエスト
2. authenticate_user! で認証チェック
3. current_user から読書実績を取得
4. @completed_books = current_user.books.completed.order(completed_at: :desc) を取得
5. show.html.erb を描画
```

### ニックネーム更新
```
1. PATCH /mypage リクエスト（params[:user][:nickname]）
2. authenticate_user! で認証チェック
3. current_user.update(nickname: ...) を実行
4. 成功 → redirect_to mypage_path, notice: ...
5. 失敗 → render :show, status: :unprocessable_entity
```

## エラーハンドリング戦略

- バリデーションエラー（ニックネーム50文字超過）は `show` を再レンダリングしてエラーメッセージを表示
- フラッシュメッセージで成功・失敗をフィードバック

## テスト戦略

### Request スペック (spec/requests/mypages_spec.rb)

- `GET /mypage` 未ログイン → ログイン画面へリダイレクト
- `GET /mypage` ログイン済み → 200 OK、ユーザー情報が表示される
- `PATCH /mypage` 有効なニックネーム → 更新成功、リダイレクト
- `PATCH /mypage` 無効なニックネーム（51文字以上） → 422、エラー表示
