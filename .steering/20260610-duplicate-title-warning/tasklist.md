# タスクリスト

## 🚨 タスク完全完了の原則

**このファイルの全タスクが完了するまで作業を継続すること**

### 必須ルール
- **全てのタスクを`[x]`にすること**
- 未完了タスク（`[ ]`）を残したまま作業を終了しない

---

## フェーズ1: データベースとモデルの準備

- [x] マイグレーションファイルの作成と実行
  - [x] `add_normalized_title_to_books` マイグレーション作成
  - [x] 既存データのバックフィル処理の実装
  - [x] マイグレーションの実行
- [x] `Book` モデルの実装
  - [x] `before_validation :set_normalized_title` コールバックの実装
  - [x] `normalize_title` クラスメソッド/インスタンスメソッドの実装
  - [x] `reading_round` インスタンスメソッドの実装
  - [x] `display_title` インスタンスメソッドの実装
  - [x] `previous_book` インスタンスメソッドの実装
- [x] `Book` モデルのテスト実装と確認
  - [x] `spec/models/book_spec.rb` にテストを追加
  - [x] `bundle exec rspec spec/models/book_spec.rb` を実行し合格を確認

## フェーズ2: コントローラとフロントエンドの実装

- [x] ルーティングの追加
  - [x] `config/routes.rb` に `check_duplicate` アクションを追加
- [x] コントローラの実装とテスト
  - [x] `BooksController#check_duplicate` の実装
  - [x] `spec/requests/books_spec.rb` にテストを追加
  - [x] `bundle exec rspec spec/requests/books_spec.rb` を実行し合格を確認
- [x] Stimulus `book-form` コントローラの修正
  - [x] `checkDuplicate` メソッドの実装 (タイトル入力時に API を Fetch)
  - [x] `submit` イベントフックの実装 (重複時 confirm ダイアログ表示)
- [x] フォームビュー `app/views/books/_form.html.erb` の修正
  - [x] 警告メッセージ表示領域の追加
  - [x] Stimulus アクションの接続

## フェーズ3: 表示の修正

- [x] 詳細画面の修正
  - [x] `app/views/books/show.html.erb` のタイトル部分を `display_title` に変更
  - [x] 前回の本へのリンクを追加
- [x] 一覧画面の修正
  - [x] `app/views/books/index.html.erb` のタイトル部分を `display_title` に変更

## フェーズ4: 品質チェックと修正

- [x] システムテストの実装と確認
  - [x] `spec/system/books/duplicate_title_warning_spec.rb` を新規作成
  - [x] `bundle exec rspec spec/system/books/duplicate_title_warning_spec.rb` を実行し合格を確認
- [x] 全テスト・リント確認
  - [x] `bundle exec rspec` を実行し、すべてのテストが通ることを確認
  - [x] `bundle exec rubocop` を実行し、リントエラーがないことを確認

---

## 実装後の振り返り
 
### 実装完了日
2026-06-10
 
### 計画と実績の差分
 
**計画と異なった点**:
- システムテストヘルパー `set_date_field` において、 `document.getElementById` に不要な `#` を指定していたJavaScriptの不具合を修正しました。
- `click_button` 直後に `Book.last` や `window.confirmCalled` を評価しようとした際、非同期リダイレクト処理との競合（Race Condition）が発生しテストが不安定になる問題が発生したため、 `expect(page).to have_current_path(/\/books\/\d+/)` による遷移待機を導入しました。
- 1番目のテスト（拒否）と2番目のテスト（承諾）でセッションCookieやアセット、ダイアログ状態が干渉する可能性を排除するため、1つの統合されたテストケース内でキャンセル流と送信承認流を順次検証する形にテストコードを整理しました。
 
**新たに必要になったタスク**:
- なし
 
**技術的理由でスキップしたタスク**（該当する場合のみ）:
- なし
 
### 学んだこと
- Capybara + headless Chrome による非同期フォーム送信テストでは、 `click_button` 直後にデータベースやJavascriptの状態を即座にアサートすると、サーバー側の処理（COMMIT等）やリダイレクト完了前に評価されてしまい失敗の原因になること。必ず `have_current_path` 等で遷移完了を待つこと。
- Turbo Drive によるページ部分書き換えとフルロードによる JavaScript 実行コンテキストのクリア動作の差異について。
 
### 次回への改善提案
- 非同期イベントが絡むシステムスペックを構築する際は、必ず遷移や表示要素の存在を待つアサーションを適時挟み、Race Conditionを未然に防止する設計にする。
