# 設計書

## アーキテクチャ概要

Devise が提供する `user_signed_in?` ヘルパーを用いて、`TopController#index` でログイン状態を判定してリダイレクトする。

## コンポーネント設計

### 1. TopController

**責務**:
- ログイン済みユーザーを `books_path` へリダイレクト
- 未ログインユーザーには Top 画面（`index`ビュー）を表示

**実装の要点**:
- `user_signed_in?` は Devise が提供するコントローラヘルパー。ApplicationController を継承しているため追加 include 不要
- `redirect_to books_path if user_signed_in?` の1行追加だけで実現可能
- `before_action` は不要（index アクションのみ対象のため）

## データフロー

### ログイン済みユーザーの / アクセス
```
1. GET / リクエスト受信
2. TopController#index が user_signed_in? を評価 → true
3. redirect_to books_path（302 Found）
```

### 未ログインユーザーの / アクセス
```
1. GET / リクエスト受信
2. TopController#index が user_signed_in? を評価 → false
3. index ビューを 200 OK でレンダリング
```

## テスト設計

- `spec/requests/top_spec.rb` を新規作成
- ログイン済みコンテキスト: `redirect_to books_path`
- 未ログインコンテキスト: `have_http_status(:ok)`
