# 設計書

## アーキテクチャ概要

`User`モデルの`after_create`コールバックを利用して、ユーザーの新規作成時にデフォルトのジャンルレコードを自動的に挿入します。
また、既存ユーザーへの移行データを作成するため、Rakeタスクを用意します。

```
[Sign Up Action]
       │
       ▼
[User.create] (Transaction Start)
       │
       ├─► [after_create: prepare_default_genres]
       │         │
       │         ▼
       │   [Genre.create!] (Insert default genres for user)
       │
       ▼ (Transaction Commit)
[User Registered & Default Genres Ready]
```

## コンポーネント設計

### 1. User モデル (`app/models/user.rb`)

**責務**:
- ユーザーアカウント作成時に、デフォルトジャンル（7種類）を挿入するコールバックメソッド `prepare_default_genres` を実行する。
- デフォルトジャンルの名前定義を持つ。

**実装の要点**:
- `after_create :prepare_default_genres` コールバックを定義。
- `prepare_default_genres` 内で、以下のジャンルを作成する：
  - `["ビジネス", "小説・文学", "技術書・専門書", "自己啓発", "エッセイ・読み物", "実用書・趣味", "その他"]`
- `Genre.create!` ではなく `genres.create!` を用いてアソシエーション経由でビルド・保存する。

### 2. 移行用 Rake タスク (`lib/tasks/genres.rake`)

**責務**:
- 既存ユーザーのうち、デフォルトジャンルが未登録であるユーザーに対して、デフォルトジャンルを登録する。

**実装の要点**:
- `namespace :genres`
- `desc '既存ユーザーにデフォルトジャンルを設定する'`
- `task setup_defaults: :environment do ... end`
- 重複を防ぐため、既に存在するジャンル名はスキップ、あるいは `find_or_create_by!` を利用する。

## テスト戦略

### ユニットテスト (Model Spec)
- `spec/models/user_spec.rb`:
  - ユーザー登録時にデフォルトジャンル（7種類）が正しく作成されることを検証。
  - ジャンル名が指定のものと一致していることを検証。

### 統合テスト / システムテスト
- ユーザー新規登録（サインアップ）のシステムスペックがあれば、そこでデフォルトジャンルがマイページに表示されることを検証。

### Rakeタスクテスト
- `spec/lib/tasks/genres_spec.rb` または `spec/tasks/genres_spec.rb` でRakeタスクが既存ユーザーに対して正しくデフォルトジャンルを作成し、重複登録を防ぐことを検証。

## ディレクトリ構造

```
app/
  models/
    user.rb (変更)
lib/
  tasks/
    genres.rake (新規)
spec/
  models/
    user_spec.rb (変更)
  lib/
    tasks/
      genres_spec.rb (新規)
```

## 実装の順序

1. `User`モデルにデフォルトジャンル自動登録ロジックを実装。
2. `User`モデルのテストを追加し、動作を検証。
3. `genres.rake` に移行用タスクを実装。
4. `genres_spec.rb` で Rake タスクのテストを実装。
5. 全テスト (RSpec, RuboCop) の実行。
