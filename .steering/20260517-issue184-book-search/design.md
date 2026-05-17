# 設計: 積読一覧画面の検索機能追加 (Issue #184)

## アプローチ概要

既存の `BooksController#index` は `current_user.books.for_index_list` のみを返している。
この一覧クエリに対して、`params` を受け取る検索スコープを `Book` モデルに追加し、
コントローラは検索条件をモデルへ委譲する。ビューには GET フォームを追加し、
検索条件の保持・クリア導線を提供する。

## 変更対象

- `app/models/book.rb`
	- 検索スコープ群（タイトル、著者、読了日時期間、複合適用）を追加
- `app/controllers/books_controller.rb`
	- `index` で検索パラメータを正規化し、検索クエリを適用
- `app/views/books/index.html.erb`
	- 検索フォームとクリアリンクを追加
- `spec/requests/books_index_spec.rb`（新規）
	- 検索条件別・複合条件・境界値の検証

## モデル設計

### 検索パラメータ

- `title`（任意）: 部分一致
- `author`（任意）: 部分一致
- `completed_from`（任意）: 読了日時の開始日
- `completed_to`（任意）: 読了日時の終了日

### スコープ方針

- SQL インジェクション回避のためバインド変数を使用
- 大文字小文字の差異を吸収するため `ILIKE` を使用（PostgreSQL）
- 期間検索は日付ベースで扱うため `completed_at` を `beginning_of_day/end_of_day` で比較
- 逆転入力（from > to）は controller で入れ替え正規化して扱う

### 疑似コード

```ruby
scope :title_like, ->(q) { where('title ILIKE ?', "%#{sanitize_sql_like(q)}%") }
scope :author_like, ->(q) { where('author ILIKE ?', "%#{sanitize_sql_like(q)}%") }

def self.filtered_for_index(params)
	relation = for_index_list
	relation = relation.title_like(params[:title]) if params[:title].present?
	relation = relation.author_like(params[:author]) if params[:author].present?
	relation = relation.completed_from(params[:completed_from]) if params[:completed_from].present?
	relation = relation.completed_to(params[:completed_to]) if params[:completed_to].present?
	relation
end
```

## コントローラ設計

- `index` で検索用パラメータのみ許可 (`params.permit`)
- `completed_from` / `completed_to` は `Date.iso8601` で安全にパース
	- 不正値は `nil` 扱い
	- 片側入力は入力された側のみ適用
	- 逆転入力は controller で swap して正規化
- `@search_params` をビューへ渡して入力値を保持

## ビュー設計

- 積読一覧のヘッダー配下に検索フォームを追加
	- `form_with url: books_path, method: :get, local: true`
	- 入力項目: 書籍名、著者名、読了日（開始/終了）
	- ボタン: 検索、クリア
- クリアは `books_path` へのリンクとして実装

## テスト設計（Request Spec）

- ログイン済みユーザーの一覧検索
	- タイトル部分一致
	- 著者部分一致
	- 読了期間（開始のみ / 終了のみ / 両方）
	- 複合条件
	- 逆転入力時の正規化
- 未ログイン時は既存通りログイン画面へリダイレクト
- 検索後も既存ソート（`for_index_list`）が維持されることを確認

	## クエリ最適化の定義

	- 一覧取得は既存の単一 `ActiveRecord::Relation` チェーン内で完結させ、追加のN+1クエリを発生させない
	- `for_index_list` を再利用し、ソート式の再実装を避けることで保守コストと回帰リスクを低減
	- 部分一致は `ILIKE` + バインド変数で実装し、SQLインジェクション耐性と可読性を両立
	- 将来的に件数増加で性能課題が出た場合は `pg_trgm` インデックス導入を検討する
