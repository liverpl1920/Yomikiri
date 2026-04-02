# 設計書

## アーキテクチャ概要

Rails MVC + Stimulus (Hotwire) によるサーバーサイドレンダリング構成。フォームのインタラクティブ要素（ページ数自動入力・ノルマ計算）は Stimulus コントローラーで担当。

```
[ブラウザ]
    │
    ▼ GET /books/new
[BooksController#new]
    │
    ▼ render
[views/books/new.html.erb]
    │ (フォーム送信)
    ▼ POST /books
[BooksController#create]
    ├── バリデーション成功 → redirect_to books/:id (show)
    └── バリデーション失敗 → render :new (エラー表示)
```

## コンポーネント設計

### 1. BooksController

**責務**:
- `new`: 新規登録フォームの表示
- `create`: 書籍の作成・バリデーション・リダイレクト
- `show`: 書籍詳細の表示（最小実装）
- `index`: 積読一覧（最小実装）

**実装の要点**:
- `before_action :authenticate_user!` で全アクションを認証ガード
- `before_action :set_book` で show アクションのオブジェクト解決
- Strong Parameters で許可フィールドを限定
- `current_user.books` スコープで常にユーザー紐付けを保証

### 2. Book モデル（追加）

**責務**:
- `deadline_cannot_be_in_the_past` バリデーション（新規作成時のみ）
- `calculate_daily_quota` メソッド（残ページ / 残日数の切り上げ）
- `remaining_pages` / `remaining_days` ヘルパーメソッド

**実装の要点**:
- 期限バリデーションは `on: :create` のみ（延長時は不要）
- `calculate_daily_quota` はゼロ除算を防ぐガード節を持つ

### 3. views/books/new.html.erb & _form.html.erb

**責務**:
- 書籍登録フォームの表示
- Stimulus data 属性の付与
- バリデーションエラーのインライン表示

**実装の要点**:
- フォームは `_form.html.erb` パーシャルとして切り出す（edit でも再利用）
- `current_page` は hidden_field で 0 を送信
- 読了対象ページ数の補足テキストを `<small>` タグで表示

### 4. views/books/show.html.erb

**責務**:
- 登録後リダイレクト先として書籍情報を最低限表示

### 5. Stimulus: book_form_controller.js

**責務**:
- 総ページ数入力時に読了対象ページ数を自動入力
- 読了期限・読了対象ページ数・現在ページ変化時にノルマをリアルタイム計算

**targets**:
- `totalPages` - 総ページ数入力フィールド
- `targetPages` - 読了対象ページ数入力フィールド
- `deadline` - 読了期限入力フィールド
- `quotaDisplay` - ノルマ表示エリア

## データフロー

### 書籍登録
```
1. GET /books/new → BooksController#new → @book = current_user.books.new
2. フォーム表示: Stimulus が total_pages の変化を監視し target_pages を自動入力
3. ノルマ計算: deadline・target_pages・current_page の変化でリアルタイム更新
4. POST /books → BooksController#create → current_user.books.build(book_params)
5. book.save → 成功: redirect_to book_path(book), 失敗: render :new
```

## エラーハンドリング戦略

### バリデーションエラー
- フォーム再表示時に `@book.errors` をインラインで表示
- フィールドごとのエラーメッセージを `.form-field__error` クラスで表示

### 認証エラー
- `authenticate_user!` (Devise) が自動的にログインページにリダイレクト

## テスト戦略

### モデル追加バリデーションのテスト (spec/models/book_spec.rb)
- `deadline_cannot_be_in_the_past` (on: :create)

### Request Specs (spec/requests/books_spec.rb)
- GET /books/new: 認証済みユーザーは200を返す
- GET /books/new: 未認証ユーザーはリダイレクト
- POST /books: 有効なパラメータで書籍が作成される
- POST /books: 無効なパラメータでエラーが表示される
- GET /books/:id: 認証済みユーザーは対象書籍を表示できる

## 追加するファイル

```
app/
  controllers/
    books_controller.rb          # 新規
  views/
    books/
      _form.html.erb             # 新規
      new.html.erb               # 新規
      show.html.erb              # 新規
      index.html.erb             # 新規（最小実装）
  javascript/
    controllers/
      book_form_controller.js    # 新規
  assets/
    stylesheets/
      _books.css                 # 新規（BEM スタイル）
config/
  routes.rb                      # 更新
spec/
  requests/
    books_spec.rb                # 新規
```

## 実装の順序

1. routes.rb にリソースを追加
2. BooksController 作成
3. Book モデルに追加ロジックを実装
4. View ファイル作成（_form, new, show, index）
5. Stimulus コントローラー作成
6. CSS スタイル追加
7. Request Spec 作成
8. テスト実行・修正
