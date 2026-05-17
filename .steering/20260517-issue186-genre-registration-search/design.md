# 設計書: 積読登録時のジャンル登録と一覧検索へのジャンル追加 (Issue #186)

## アーキテクチャ概要

既存のRails MVC構成を維持し、以下の3層に限定して変更します。

- Model: `Book` に `genre` 属性のバリデーションと検索スコープを追加
- Controller: `BooksController` の strong params / index検索正規化 / 外部APIレスポンス整形を更新
- View + Stimulus: 登録フォームと一覧検索フォームにジャンルUIを追加し、自動入力結果を反映

```text
BooksController#search
	-> openBD / Google Books API
	-> title, author, total_pages, cover_image_url, genre をJSON返却

book_form_controller.js
	-> books/search の結果をフォームに反映
	-> genre が取得できれば genre 入力欄を自動更新

BooksController#index
	-> title/author/completed_from/completed_to/genre を正規化
	-> Book.filtered_for_index で複合検索
```

## コンポーネント設計

### 1. Bookモデル

**責務**:
- ジャンル属性の妥当性を担保する
- 一覧検索でジャンル部分一致条件を適用する

**実装の要点**:
- `genre` は任意入力、最大文字数を設定（他フィールドと同様に長さ制約）
- `genre_like` スコープを追加し、`filtered_for_index` に統合する

### 2. BooksController

**責務**:
- ジャンルの保存を許可する（`book_params`）
- 一覧検索パラメータにジャンルを取り込み正規化する
- API検索レスポンスにジャンルを含める

**実装の要点**:
- `normalized_index_search_params` に `genre` を追加
- ISBN検索時はopenBDデータからジャンル候補を抽出
- タイトル検索時はGoogle Booksの`categories`をジャンルとして取り込み

### 3. 登録フォーム + Stimulus

**責務**:
- ジャンル手入力欄を提供する
- 自動取得成功時にジャンル欄を補完する
- 自動取得失敗時でも入力欄を維持して手入力可能にする

**実装の要点**:
- `_form.html.erb` に `genre` フィールドを追加
- `book_form_controller.js` の `_fillFormFromSearch` 対象に `genre` を追加
- 既存メッセージ構成（不足項目表示）を壊さない

## データフロー

### ユースケース1: 登録時のジャンル自動入力
1. ユーザーがタイトル入力を完了しフォーカスアウト
2. `book_form_controller.js` が `/books/search?q=...` を実行
3. `BooksController#search` が外部APIから書誌情報を取得し、`genre`付きで返却
4. Stimulusがフォームへ値を反映（取得不可なら既存入力を維持）

### ユースケース2: 一覧でジャンル複合検索
1. ユーザーが一覧検索フォームにジャンルを入力
2. `BooksController#index` が検索条件を正規化
3. `Book.filtered_for_index` が複合条件を順次適用
4. 検索結果を既存ソート規則で表示

## エラーハンドリング戦略

### モデル
- `genre` 長さ超過はバリデーションエラーとして返す

### 外部API
- 既存の`GoogleBooksApiError`処理を流用
- ジャンル取得できない場合は`nil`/空文字として扱い、失敗にしない

## テスト戦略

### ユニットテスト（Model）
- `genre` の長さバリデーション
- `genre_like` スコープ
- `filtered_for_index` のジャンル条件適用

### 統合テスト（Request / System）
- `POST /books` でジャンル保存
- `GET /books` のジャンル単体・複合検索
- タイトル/ISBN自動取得レスポンスにジャンルが含まれる場合の反映

## 依存ライブラリ

新規ライブラリ追加は不要です。

## ディレクトリ構造

```text
app/controllers/books_controller.rb           # 更新
app/models/book.rb                           # 更新
app/views/books/_form.html.erb               # 更新
app/views/books/index.html.erb               # 更新
app/javascript/controllers/book_form_controller.js  # 更新
db/migrate/*_add_genre_to_books.rb           # 追加
spec/models/book_spec.rb                     # 更新
spec/requests/books_spec.rb                  # 更新
spec/requests/books_index_spec.rb            # 更新
spec/system/books/isbn_autofetch_spec.rb     # 更新（必要最小限）
spec/factories/books.rb                      # 更新
```

## 実装の順序

1. DBマイグレーションとモデル/strong params更新
2. API検索レスポンスとフォーム自動入力更新
3. 一覧検索UI・クエリ拡張
4. RSpec更新と検証

## セキュリティ考慮事項

- 既存のStrong Parametersに`genre`を明示追加し、意図しない属性代入を防ぐ
- 検索条件は既存同様にActiveRecordクエリでバインドし、SQLインジェクションを回避する

## パフォーマンス考慮事項

- ジャンル検索は既存同様`ILIKE`の部分一致を採用（MVPとして妥当）
- 将来的なデータ増加時は`pg_trgm`インデックスを検討する

## 将来の拡張性

- 単一文字列の`genre`設計を維持しつつ、将来はタグテーブルへの正規化に移行可能
- 外部APIごとのジャンル表記ゆれは将来的に正規化辞書で吸収可能
