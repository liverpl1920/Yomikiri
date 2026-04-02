# タスクリスト: 積読登録機能 (Issue #14)

## 🚨 タスク完全完了の原則

**このファイルの全タスクが完了するまで作業を継続すること**

---

## フェーズ1: ルーティングとコントローラー

- [x] config/routes.rb に books リソースを追加
- [x] app/controllers/books_controller.rb を作成
  - [x] before_action :authenticate_user! を設定
  - [x] before_action :set_book (show アクション用)
  - [x] new アクション実装
  - [x] create アクション実装（成功時: books#show へリダイレクト、失敗時: render :new）
  - [x] show アクション実装
  - [x] index アクション実装（最小実装）
  - [x] book_params private メソッド実装

## フェーズ2: モデルの拡張

- [x] Book モデルに deadline_cannot_be_in_the_past バリデーション追加（on: :create）
- [x] Book モデルに calculate_daily_quota メソッド追加
- [x] Book モデルに remaining_pages メソッド追加
- [x] Book モデルに remaining_days メソッド追加

## フェーズ3: ビュー作成

- [x] app/views/books/index.html.erb を作成（最小実装）
- [x] app/views/books/_form.html.erb を作成
  - [x] タイトルフィールド（必須）
  - [x] 著者フィールド（任意）
  - [x] 総ページ数フィールド（必須）
  - [x] 読了対象ページ数フィールド（必須、補足テキストあり）
  - [x] 読了期限フィールド（日付ピッカー、必須）
  - [x] current_page の hidden_field (値: 0)
  - [x] ノルマ表示エリア
  - [x] Stimulus data 属性の付与
  - [x] バリデーションエラー表示
- [x] app/views/books/new.html.erb を作成
- [x] app/views/books/show.html.erb を作成（最小実装）

## フェーズ4: Stimulus コントローラー

- [x] app/javascript/controllers/book_form_controller.js を作成
  - [x] targets 定義 (totalPages, targetPages, deadline, quotaDisplay)
  - [x] total_pages 変化時に target_pages を自動入力するメソッド
  - [x] ノルマ計算メソッド（残ページ / 残日数の切り上げ）
  - [x] connect 時に初期表示を計算

## フェーズ5: CSS スタイル

- [x] app/assets/stylesheets/books.css を作成
  - [x] .book-form のスタイル（BEM）
  - [x] .form-field のスタイル（BEM）
  - [x] .form-field__error のスタイル
  - [x] .quota-preview のスタイル
  - [x] .book-show の基本スタイル
  - [x] .book-list の基本スタイル（index 用）
- [x] application.css に books.css を require_tree . で自動読み込み（require_tree . で対応済み）

## フェーズ6: テスト

- [x] spec/requests/books_spec.rb を作成
  - [x] GET /books/new: 認証済みユーザーは 200 を返す
  - [x] GET /books/new: 未認証ユーザーはリダイレクト
  - [x] POST /books: 有効なパラメータで書籍が作成され詳細画面へリダイレクト
  - [x] POST /books: 無効なパラメータ（タイトルなし）でフォーム再表示
  - [x] GET /books/:id: 認証済みユーザーは自分の書籍を表示できる
  - [x] GET /books/:id: 他ユーザーの書籍は 404 またはリダイレクト
- [x] spec/models/book_spec.rb に deadline_cannot_be_in_the_past テストを追加

## フェーズ7: 品質チェック

- [x] bundle exec rspec spec/models/book_spec.rb でモデルテストが通ることを確認
- [x] bundle exec rspec spec/requests/books_spec.rb でリクエストテストが通ることを確認
- [x] bundle exec rubocop app/controllers/books_controller.rb app/models/book.rb でリントが通ることを確認
- [x] bundle exec brakeman --no-pager でセキュリティチェック

---

## 実装後の振り返り

### 実装完了日
2026-04-03

### 計画と実績の差分

**計画と異なった点**:
- `before_action :set_book, only: [:show, :update_progress, :change_deadline, :complete]` に未実装アクションを列挙していたが、Rails 7.2 の `raise_on_missing_callback_actions` により実行エラーになるため `:show` のみに修正した。未実装アクション用の `before_action` は各アクション実装時に追加する設計に変更
- `_books.css` のアンダースコアプレフィックスを廃止し `books.css` に変更（既存ファイルの命名規則に準拠）
- `spec/requests/books_spec.rb` の「他ユーザー書籍アクセス」テストで `raise_error` でなく `have_http_status(:not_found)` に変更した（`show_exceptions: :rescuable` により ActiveRecord::RecordNotFound が 404に変換される）
- バリデーターレビュー後、`author` フィールドの長さバリデーションを追加し、`ja.yml` の重複エラーキーを削除

### 学んだこと
- Rails 7.2 の `raise_on_missing_callback_actions` は `before_action` の `:only` に存在しないアクション名を書くとエラーになる
- テスト環境では `action_dispatch.show_exceptions = :rescuable` により、`ActiveRecord::RecordNotFound` が例外としてではなく 404 HTTP レスポンスとして返される
- Stimulus のコントローラー名は `book-form` のように kebab-case で記述し、ファイル名は `book_form_controller.js` のように snake_case にする

### 次回への改善提案
- 後続 Issue で `update_progress`, `change_deadline`, `complete` アクションを実装する際は、対応する `before_action :set_book` を追加すること
- 本リリースで `application_controller.rb` に `rescue_from ActiveRecord::RecordNotFound` を追加し、エラーページを適切にカスタマイズする
- 本リリースで Book モデルのスコープ（`active`、`by_deadline`、`overdue`）と `daily_quota` カラムを追加検討
- `functional-design.md` の Book モデル定義を MVP スコープに合わせて更新する（`daily_quota` カラムなし、スコープ未実装を明記）
