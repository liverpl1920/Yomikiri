# 設計書

## アーキテクチャ概要

既存の Rails MVC + Hotwire（Stimulus）構成を維持し、登録フォームの UI と `book_form_controller.js` の責務を整理する。

```text
View(app/views/books/_form.html.erb)
	-> Stimulus(book_form_controller.js)
			-> GET /books/search
					-> BooksController#search
```

## コンポーネント設計

### 1. 登録フォーム（books/_form.html.erb）

責務:
- ユーザーが最小入力で書籍登録できる UI を提供する。
- タイトル入力時の自動取得結果メッセージを表示する。

実装の要点:
- `book-search` セクションを削除する。
- `cover_image_url` 入力欄を削除する。
- `data-book-form-target="titleStatus"` は維持し、自動取得結果のみを表示する。

### 2. Stimulus（book_form_controller.js）

責務:
- タイトル入力を起点に検索APIを呼び、著者・総ページ数を補完する。
- ノルマプレビュー（既存機能）を維持する。

実装の要点:
- `isbnSection` / `isbn` / `isbnStatus` ターゲットと関連メソッドを削除する。
- `fetchByIsbn` と `cover_image_url` 直接代入処理を削除する。
- 取得失敗時は `titleStatus` のメッセージ表示のみに統一する。

### 3. テスト

責務:
- UI削除とタイトル起点の自動取得フローを検証する。

実装の要点:
- `book-search` コントローラー依存の system spec を削除または置換する。
- `isbn_autofetch_spec` を新UIに合わせて更新する（ISBNフォールバック期待を削除）。
- 必要に応じて request spec の期待値を維持確認する。

## データフロー

### タイトル起点の自動補完
1. ユーザーがタイトルを入力し、フォーカスを外す。
2. `book_form_controller#autoFetchByTitle` が `/books/search?q=タイトル` を呼ぶ。
3. 成功時に著者・総ページ数をフォームへ反映し、ステータスを更新する。
4. 失敗時は `titleStatus` に失敗メッセージを表示する。

## エラーハンドリング戦略

- APIエラーは `BooksController#search` の既存仕様を維持する。
- フロント側は失敗時にフォーム内メッセージを表示し、追加入力導線は出さない。

## テスト戦略

### システムテスト
- 登録画面に不要欄が表示されないこと。
- タイトル自動取得成功時に著者・総ページ数が補完されること。
- 取得失敗時に失敗メッセージが表示されること。

### リクエストテスト
- `/books/search` の既存成功/失敗パスが維持されること（回帰防止）。

## 依存ライブラリ

- 追加なし。

## ディレクトリ構造

```text
変更:
- app/views/books/_form.html.erb
- app/javascript/controllers/book_form_controller.js
- app/assets/stylesheets/books.css
- spec/system/books/isbn_autofetch_spec.rb
- spec/system/books/book_search_spec.rb (削除)
```

## 実装の順序

1. ステアリング作成
2. フォームとStimulusの不要導線削除
3. テスト更新
4. RSpec/RuboCop実行
5. 振り返り記載・PR作成

## セキュリティ考慮事項

- 既存の検索APIエラーハンドリングと認証要件は変更しない。

## パフォーマンス考慮事項

- 不要UI/JS処理を削減するため、画面ロード時のDOMとイベント管理が軽量化される。

## 将来の拡張性

- 将来 ISBN 手入力導線が必要になっても、Stimulus内で再追加可能なようにタイトル起点ロジックは独立して維持する。
