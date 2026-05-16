# 設計書

## アーキテクチャ概要

Rails標準MVC構成を維持し、既存の `Book` バリデーションと `BooksController#create` の保存フローを活用して、フォーム入力の拡張のみで要件を満たす。

```
Books/new(_form)
	-> params[:book][:current_page] (任意)
	-> BooksController#create
	-> Book validations
	-> save
	-> books/index, books/show で既存進捗表示ロジックに反映
```

## コンポーネント設計

### 1. 書籍登録フォーム（`app/views/books/_form.html.erb`）

責務:
- `current_page` を hidden 固定ではなく任意入力として受け付ける。
- 未入力時に 0 として送信できるUI/パラメータ構成を維持する。

実装の要点:
- `number_field :current_page` を追加し、`min: 0` を設定する。
- エラー表示は既存のフィールド表示パターン（`form-field__error`）に合わせる。

### 2. モデルバリデーション（`app/models/book.rb`）

責務:
- `current_page` の妥当性を保証する。
- `target_pages`/`total_pages` との整合性を保証する。

実装の要点:
- 既存の `current_page_not_exceed_target_pages` を活用。
- `total_pages` 超過を明示する独自バリデーションを追加。
- 既存 i18n のエラーメッセージ規約に従う。

### 3. リクエスト/モデルスペック

責務:
- 正常系（未入力/入力あり）と異常系（負数/上限超過）を回帰テストで担保する。

実装の要点:
- `POST /books` request spec に `current_page` の入力有無と境界値ケースを追加。
- `Book` model spec に `current_page` と `total_pages` 境界チェックを追加。

## データフロー

### 書籍登録（既読ページ任意入力）
1. ユーザーが `current_page` を空または数値で入力する。
2. `book[current_page]` が `BooksController#create` に渡る（空ならコントローラーで 0 補完）。
3. `Book` モデルで範囲チェックを行い、妥当なら保存する。
4. 一覧/詳細は既存ロジックで保存済み `current_page` を表示する。

## エラーハンドリング戦略

### カスタムエラークラス

新規カスタムエラークラスは追加しない。既存の ActiveModel バリデーションエラーを利用する。

### エラーハンドリングパターン

- バリデーション失敗時は `render :new, status: :unprocessable_entity` を維持する。
- エラー文言は `config/locales/ja.yml` で管理する。

## テスト戦略

### ユニットテスト
- `Book` の `current_page` が `total_pages` を超えた場合に無効となること。
- `Book` の `current_page` が負数のとき無効となること。

### 統合テスト
- `POST /books` で `current_page` 未入力時に 0 保存されること。
- `POST /books` で `current_page` 入力時に保存値へ反映されること。
- `POST /books` で不正値時に 422 とエラー表示となること。

## 依存ライブラリ

新規ライブラリ追加なし。

## ディレクトリ構造

```
app/models/book.rb
app/controllers/books_controller.rb
app/views/books/_form.html.erb
config/locales/ja.yml
spec/models/book_spec.rb
spec/requests/books_spec.rb
```

## 実装の順序

1. フォームの入力欄追加とパラメータ受け渡し整備
2. モデルバリデーションとエラーメッセージ追加
3. request/model spec を拡充して回帰保証
4. テスト・Lint実行で最終確認

## セキュリティ考慮事項

- Strong Parameters で `current_page` 以外の不要パラメータは許可しない（現状維持）。
- 数値バリデーションにより負値/過大値を拒否する。

## パフォーマンス考慮事項

- 単一フォーム項目の追加のみで、クエリ数や外部API呼び出し数は増加しない。

## 将来の拡張性

- 将来的に編集画面で同項目を公開する際、同じバリデーションを再利用できる。
- 進捗初期値テンプレート（例: しおり機能）実装時の基盤として利用可能。
