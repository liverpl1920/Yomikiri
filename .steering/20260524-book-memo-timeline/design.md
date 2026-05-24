# 設計

## アーキテクチャ概要

Rails 標準の MVC パターンに従い、書籍メモを独立したリソースとして設計する。

## データモデル設計

### 新テーブル: `book_memos`

| カラム | 型 | 制約 | 説明 |
|--------|-----|------|------|
| id | bigint | PK | プライマリキー |
| book_id | bigint | FK NOT NULL | 書籍ID |
| content | text | NOT NULL | メモ本文（最大2000文字） |
| created_at | datetime | NOT NULL | 作成日時（タイムライン表示に使用） |
| updated_at | datetime | NOT NULL | 更新日時 |

### リレーション変更

`Book` モデルに `has_many :book_memos, dependent: :destroy` を追加

### 既存 `books.memo` カラム

- カラム自体は残す（削除マイグレーション不要）
- UI からの入力フォームは非表示にする（後方互換性のため残す）
- 既存データはそのまま保持（読取専用として残すか非表示にする）

## コントローラー設計

### 新規: `BookMemosController`

```
app/controllers/book_memos_controller.rb
```

| アクション | HTTPメソッド | URL | 説明 |
|-----------|-------------|-----|------|
| create | POST | /books/:book_id/book_memos | メモを追加 |
| destroy | DELETE | /books/:book_id/book_memos/:id | メモを削除 |

### ルーティング追加

```ruby
resources :books do
  resources :book_memos, only: [:create, :destroy]
  ...
end
```

## ビュー設計

### `app/views/books/show.html.erb` のメモセクション変更

既存の `<section class="book-show__memo">` を書き換えて：
1. 新規メモ追加フォーム（text_area + 投稿ボタン）
2. メモタイムライン一覧（新しい順）

```html
<section class="book-show__memo-timeline">
  <h2>コメント・メモ</h2>
  <!-- 追加フォーム -->
  <form> ... </form>
  <!-- タイムライン -->
  <ul class="memo-timeline">
    <li class="memo-timeline__item">
      <time>2026-05-24 12:00</time>
      <p>メモ本文</p>
      <form method="delete">削除</form>
    </li>
  </ul>
</section>
```

## バリデーション

### `BookMemo` モデル

- `content`: presence: true, length: { maximum: 2000 }

## テスト計画

- `spec/models/book_memo_spec.rb`: モデルバリデーションテスト
- `spec/requests/book_memos_spec.rb`: リクエストスペック (create, destroy, 認可)
- `spec/factories/book_memos.rb`: ファクトリ定義
