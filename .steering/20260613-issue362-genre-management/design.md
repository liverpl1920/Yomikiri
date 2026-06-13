# 設計書

## アーキテクチャ概要

Rails 標準の MVC パターン + Turbo Stream による部分更新を採用。

```
User → MypagePage → GenreCard
                       ↓ Turbo Frames
                    GenresController (CRUD)
                       ↓
                    Genre Model (user_id, name)
                       ↓ DB
                    genres table
```

## コンポーネント設計

### 1. Genre モデル

**責務**:
- ユーザー固有のジャンルマスタを保持する

**実装の要点**:
- `belongs_to :user`
- `validates :name, presence: true, uniqueness: { scope: :user_id }`
- ユーザーあたりの最大50件バリデーション

### 2. GenresController

**責務**:
- ジャンル CRUD のエンドポイントを提供する

**実装の要点**:
- `before_action :authenticate_user!`
- 操作対象を `current_user.genres` でスコープし、他ユーザーのジャンルへのアクセスを防ぐ
- レスポンスは Turbo Stream（HTML部分更新）を基本とする

### 3. ビュー

**マイページ（genres/_genre.html.erb）**:
- Turbo Frame でジャンル1件を包む
- 表示モード / 編集モードの切り替えをシンプルなフォームで実現

**書籍フォーム（_form.html.erb）**:
- `<datalist id="genre-options">` を追加し、ユーザー登録ジャンルを `<option>` として列挙する
- `f.text_field :genre, list: "genre-options"` で連携

## データフロー

### ジャンル追加
```
1. ユーザーがマイページの追加フォームにジャンル名を入力して送信
2. GenresController#create が呼ばれる
3. current_user.genres.build(genre_params) でジャンルを作成
4. 成功時: Turbo Stream でジャンル一覧に行を追加、フォームをリセット
5. 失敗時: Turbo Stream でエラーメッセージを表示
```

### ジャンル編集
```
1. ユーザーが「編集」リンクをクリック
2. Turbo Frame 内に編集フォームを表示
3. GenresController#update で更新
4. 成功時: Turbo Stream でジャンル行を更新
5. 失敗時: Turbo Stream でエラーメッセージを表示
```

### ジャンル削除
```
1. ユーザーが「削除」ボタンをクリック（確認なし / または confirm ダイアログ）
2. GenresController#destroy で削除
3. Turbo Stream でジャンル行を削除
```

## ルーティング

```ruby
resource :mypage, only: [:show, :update] do
  get :stats
  resources :genres, only: [:create, :update, :destroy]
end
```

（ `mypage_genres_path` など mypage 以下のネスト）

## セキュリティ考慮事項

- `authenticate_user!` で未認証アクセスをブロック
- `current_user.genres.find(params[:id])` でスコープを限定し、他ユーザーのジャンルへのアクセスを防ぐ（RecordNotFound は ApplicationController でハンドリング済み）

## パフォーマンス考慮事項

- ジャンルはユーザーあたり最大50件を想定しているためページネーション不要

## ディレクトリ構造

```
db/migrate/
  YYYYMMDDHHMMSS_create_genres.rb

app/
  models/
    genre.rb                      [NEW]
  controllers/
    genres_controller.rb          [NEW]
  views/
    genres/
      _genre.html.erb             [NEW]
      _genre_form.html.erb        [NEW]
      create.turbo_stream.erb     [NEW]
      update.turbo_stream.erb     [NEW]
      destroy.turbo_stream.erb    [NEW]
  assets/stylesheets/
    mypages.css                   [MODIFY]

spec/
  models/
    genre_spec.rb                 [NEW]
  requests/
    genres_spec.rb                [NEW]
  factories/
    genres.rb                     [NEW]
```
