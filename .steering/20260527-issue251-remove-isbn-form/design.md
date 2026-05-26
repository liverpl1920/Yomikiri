# 設計書

## アーキテクチャ概要

Rails標準MVC + Hotwire(Stimulus)構成を維持し、View層のISBN入力ブロックを削除する。併せて、View変更で不要になるStimulusのISBN入力ハンドラを除去してUIイベントの整合性を保つ。

```mermaid
graph TD
	U[ユーザー] --> V[books/_form.html.erb]
	V --> S[book_form_controller.js]
	S --> A[/books/search API]
	A --> C[BooksController#search]
```

今回の変更では V-S 間の ISBN入力イベント経路を削除し、タイトルベース経路のみ残す。

## コンポーネント設計

### 1. フォームビュー (`app/views/books/_form.html.erb`)

責務:
- ISBN入力行、ISBN取得ボタン、ISBNヒント、ISBNステータス表示を削除する。
- 書影フィールド周辺の文言をISBN依存から汎用文言へ更新する。

実装の要点:
- hiddenの`book[isbn]`は既存パラメータ互換性維持のため残す。
- `form_with` の submit アクションは維持し、オート補完挙動へ影響を出さない。

### 2. Stimulus (`app/javascript/controllers/book_form_controller.js`)

責務:
- ISBN入力targetと関連メソッドを削除し、未使用ハンドラを除去する。
- タイトルベース補完・ステータス表示・書影プレビュー処理を維持する。

実装の要点:
- `static targets` から `isbnInput` と `isbnStatus` を削除。
- `fetchByIsbn` / `fetchByIsbnOnEnter` / `_isValidIsbn` / `_setIsbnStatus` を削除。
- `_fillFormFromSearch` 内の hidden isbn 代入は維持する。

### 3. テスト (`spec/requests`, `spec/system`)

責務:
- ISBN入力UIが表示される前提の期待値を更新する。
- タイトル補完導線の文言変化を反映する。

実装の要点:
- `spec/requests/books_spec.rb` の新規画面UI期待値を非表示確認へ更新。
- `spec/system/books/isbn_autofetch_spec.rb` は登録画面起点のISBN入力UI依存シナリオを削除または代替。
- 既存のタイトル補完シナリオと登録作成シナリオで回帰を担保する。

## データフロー

### 登録画面での書籍情報入力
1. ユーザーがタイトル入力後、既存のタイトル補完フローで書籍情報取得を試みる。
2. 取得結果はタイトルステータス表示とフォーム項目更新に反映される。
3. ユーザーは必要に応じて書影をアップロードして登録を完了する。

## エラーハンドリング戦略

- 新規エラークラスは追加しない。
- タイトル補完時の既存エラーメッセージを維持し、ISBN誘導文言のみ調整する。

## テスト戦略

### ユニット/リクエストテスト
- 新規登録画面レスポンスに ISBN入力UI要素が存在しないことを確認。
- 既存の `isbn` パラメータ保存互換テストは維持し、DB互換性を担保。

### システムテスト
- 登録画面でISBN入力UIに依存する操作を削除。
- タイトル補完、書影プレビュー、登録成功を確認して回帰を検知。

## 依存ライブラリ

追加なし。

## ディレクトリ構造

```text
app/views/books/_form.html.erb                # ISBN UI削除・文言調整
app/javascript/controllers/book_form_controller.js  # ISBN関連メソッド除去
spec/requests/books_spec.rb                   # UI表示期待値更新
spec/system/books/isbn_autofetch_spec.rb      # ISBN UI依存シナリオ更新
spec/system/books/book_form_feedback_spec.rb  # 文言更新(必要時)
```

## 実装の順序

1. フォームUIからISBN入力ブロックを削除し、補助文言を更新する。
2. Stimulus側のISBN依存処理を除去し、不要ターゲットを整理する。
3. Request/Systemテストを更新し、対象テストを実行する。
4. RSpec + RuboCop を実行して回帰を確認する。

## セキュリティ考慮事項

- 入力項目削減のみであり、認証認可・権限モデルの変更はない。
- `book_params` の `:isbn` 許可は後方互換性維持のため現状維持する。

## パフォーマンス考慮事項

- 不要なフロントイベント削除により、フォーム初期化コストがわずかに減少する。

## 将来の拡張性

- 将来、`isbn` カラム廃止を行う際は migration と API返却フィールドの整理を別Issueで対応する。
