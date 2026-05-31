# 設計書

## アーキテクチャ概要

フロントエンド（Stimulus）中心の変更で解決する。サーバー側の検索エンドポイントは既存の `BooksController#search` を再利用する。

```mermaid
flowchart TD
  A[タイトル入力] --> B[候補表示のみ]
  B --> C[情報取得ボタン押下]
  C --> D[book_form_controller fetch]
  D --> E[/books/search]
  E --> F[フォーム反映]
  F --> G[status/preview更新]
```

## コンポーネント設計

### 1. `app/views/books/_form.html.erb`

責務:
- タイトル入力欄から自動取得イベントを除去する。
- ボタン押下による明示的な取得アクションを定義する。

変更点:
- `blur->book-form#autoFetchByTitle` を削除。
- `submit->book-form#submitWithAutoFetch` を削除。
- `type=button` の「情報取得」ボタンを追加し `click->book-form#fetchByTitle` を紐付け。

### 2. `app/javascript/controllers/book_form_controller.js`

責務:
- 手動取得操作の実行制御。
- 取得結果のフォーム反映（未入力項目のみ更新）。

変更点:
- `fetchByTitle` を公開メソッドとして追加。
- 既存の `autoFetchByTitle` / `submitWithAutoFetch` を廃止。
- `_fillFormFromSearch` の反映条件を「入力済み項目は保持」に統一。

### 3. System Spec

対象:
- `spec/system/books/book_form_feedback_spec.rb`
- `spec/system/books/isbn_autofetch_spec.rb`

方針:
- 旧仕様（blur 自動取得）依存のテストをボタン押下仕様へ更新。
- 「blurのみでは取得されない」「ボタン押下で取得される」を明示的に検証。

## データフロー

1. ユーザーがタイトル入力。
2. オートコンプリート候補表示（任意選択）。
3. ユーザーが「情報取得」ボタン押下。
4. `book_form_controller#fetchByTitle` が `/books/search` へリクエスト。
5. 取得結果を未入力項目にのみ反映。
6. ステータス表示と書影プレビュー更新。

## エラーハンドリング戦略

- タイトル未入力時: 「タイトルを入力してください。」を表示してAPI呼び出ししない。
- API失敗時: 既存メッセージ（取得失敗/エラー）を表示。
- 取得0件時: 既存メッセージを維持。

## テスト戦略

- システムテストでUI操作（入力/blur/ボタン押下）を検証。
- 回帰として既存の成功・失敗・プレビューケースを維持。
- `current_page` と `target_pages` の上書き抑止ケースを追加。

## ディレクトリ構造

変更対象:

```
app/views/books/_form.html.erb
app/javascript/controllers/book_form_controller.js
spec/system/books/book_form_feedback_spec.rb
spec/system/books/isbn_autofetch_spec.rb
```

## 実装の順序

1. フォームイベント配線変更（自動取得停止＋ボタン追加）
2. Stimulusコントローラーの取得トリガー整理と上書き抑止拡張
3. システムテスト更新
4. RSpec/RuboCop実行と修正

## セキュリティ考慮事項

- 既存のサーバー側サニタイズ/レスポンス処理に依存し、新規の外部入力経路は追加しない。

## パフォーマンス考慮事項

- blur時自動取得を廃止することで不要なAPI呼び出し回数を削減できる。
