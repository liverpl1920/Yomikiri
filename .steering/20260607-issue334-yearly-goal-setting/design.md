# 設計書 (Issue #334)

## アーキテクチャ概要

Rails標準のMVCパターンに基づき実装します。
`User` モデルに `yearly_goal` カラムを追加し、マイページから更新可能にします。ダッシュボードでは `current_user` オブジェクトから目標値を取得して表示します。

```
[MypagesView] --(PATCH /mypage)--> [MypagesController#update]
                                               │
                                               ▼
                                      [User model] (validation & save)
                                               │
                                               ▼
[DashboardsView] <--(current_user.yearly_goal)-- [Database (users.yearly_goal)]
```

## コンポーネント設計

### 1. データベースの変更

**マイグレーションファイル作成**:
`AddYearlyGoalToUsers` マイグレーション。
- `users` テーブルに `yearly_goal` カラムを追加。
- 型: `integer`
- デフォルト値: `50`
- `null: false`

### 2. User モデル (`app/models/user.rb`)

**バリデーションの追加**:
- `yearly_goal` は必須 (`presence: true`)。
- `yearly_goal` は整数のみ (`only_integer: true`)。
- `yearly_goal` は 1 以上 (`greater_than_or_equal_to: 1`)。

### 3. MypagesController (`app/controllers/mypages_controller.rb`)

**ストロングパラメータの変更**:
- `nickname_params` を `user_params` にリネーム。
- 許可するパラメータに `:yearly_goal` を追加。
- `update` アクションでの成功フラッシュメッセージを「プロフィールを更新しました。」に更新。

### 4. ビュー

#### マイページ画面 (`app/views/mypages/show.html.erb`)
- プロフィールリストに「年間目標」を表示 (`current_user.yearly_goal` 冊)。
- 編集フォームのタイトルを「プロフィールを変更する」に変更。
- 年間目標の入力欄を追加 (`number_field :yearly_goal`, `min: 1`, `class: 'mypage__form-input'`)。
- エラー表示エリアを `current_user.errors.any?` を用いた `full_messages` のループ処理に改修。

#### ダッシュボード画面 (`app/views/dashboards/show.html.erb`)
- ハードコードされている `yearly_target = 50` を `yearly_target = current_user.yearly_goal` に修正。

#### 翻訳ファイル (`config/locales/ja.yml`, `config/locales/en.yml`)
- `activerecord.attributes.user.yearly_goal` に「年間目標」およびその英語定義を追加。

## データフロー

### 年間目標の更新フロー
```
1. ユーザーがマイページで「ニックネーム」や「年間目標」を入力して「更新する」ボタンをクリック。
2. MypagesController#update が呼び出され、user_params を用いて current_user.update を実行。
3. バリデーションエラーがなければ、DBの users.yearly_goal が更新される。
4. マイページ画面へリダイレクトされ、更新成功フラッシュメッセージが表示される。
```

## エラーハンドリング戦略

- バリデーションエラー時は `MypagesController#update` 内で `render :show, status: :unprocessable_entity` を実行。
- フォーム上部で `current_user.errors.full_messages` をリスト表示する。

## テスト戦略

### ユニットテスト (`spec/models/user_spec.rb`)
- `yearly_goal` のバリデーション（存在性、整数であること、1以上であること）を検証。

### 統合テスト (`spec/requests/mypages_spec.rb` 等)
- `yearly_goal` が正しく更新されること、及び不正な値でエラーになることを検証。

### システムテスト (`spec/system/mypages_spec.rb`, `spec/system/dashboards_spec.rb`)
- マイページで年間目標を変更し、それがダッシュボードに反映されることをブラウザ操作ベースで検証。

## ディレクトリ構造

```
app/
├── controllers/
│   └── mypages_controller.rb (ストロングパラメータ変更、メッセージ変更)
├── models/
│   └── user.rb (バリデーション追加)
└── views/
    ├── dashboards/
    │   └── show.html.erb (年間目標の参照先変更)
    └── mypages/
        └── show.html.erb (設定欄と表示の追加)
db/
└── migrate/
    └── 2026XXXXXXXXXX_add_yearly_goal_to_users.rb (新規マイグレーション)
config/
└── locales/
    ├── ja.yml (翻訳の追加)
    └── en.yml (翻訳の追加)
spec/
├── models/
│   └── user_spec.rb (バリデーションテスト)
├── requests/
│   └── mypages_spec.rb (更新リクエストテスト)
└── system/
    └── mypages_spec.rb (画面操作のテスト)
```

## 実装の順序

1. データベースの変更（マイグレーションの作成・実行）
2. `User` モデルへのバリデーション追加とテスト作成
3. `MypagesController` のストロングパラメータ拡張
4. マイページ画面の表示・フォーム追加、エラー表示修正
5. ダッシュボード画面への年間目標値のバインド
6. テストの作成・実行（ユニットテスト、リクエストテスト、システムテスト）
7. RuboCopによる静的解析と修正

## セキュリティ考慮事項

- `yearly_goal` はストロングパラメータで明示的に許可し、不正なパラメータ（例: admin権限など他のカラム）が上書きされないようにする。
- ログインユーザー本人のレコードのみが更新可能であることを保証（Deviseによる `authenticate_user!` と `current_user` の利用により保証済み）。
