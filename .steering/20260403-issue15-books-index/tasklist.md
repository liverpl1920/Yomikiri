# タスクリスト

## 🚨 タスク完全完了の原則

**このファイルの全タスクが完了するまで作業を継続すること**

---

## フェーズ1: モデル拡張

- [x] `app/models/book.rb` にノルマ計算・ビジュアライザー関連メソッドを追加
  - [x] `daily_quota` インスタンスメソッド（残ページ÷残日数、切り上げ）
  - [x] `progress_percentage` インスタンスメソッド（進捗率%）
  - [x] `days_remaining` インスタンスメソッド（残り日数）
  - [x] `deadline_urgency_class` インスタンスメソッド（CSSクラス名）
  - [x] `for_index_list` スコープ（未了本を期限順→読了本を期限順）

## フェーズ2: コントローラ・ルーティング

- [x] `config/routes.rb` に `resources :books, only: [:index]` を追加
- [x] `app/controllers/books_controller.rb` を新規作成
  - [x] `before_action :authenticate_user!` で認証必須
  - [x] `index` アクション: `current_user.books.for_index_list` を取得

## フェーズ3: ビュー・スタイル

- [x] `app/views/books/index.html.erb` を新規作成
  - [x] ページタイトル（content_for）
  - [x] 「+ 本を追加する」ボタン（将来の books/new へのリンク）
  - [x] 書籍カード一覧（@books.each）or Empty State（@books.empty?）
  - [x] 書籍カード構造（BEM: .book-card / .book-card__cover / .book-card__body 等）
  - [x] 賞味期限ビジュアライザー適用（deadline_urgency_class）
  - [x] 書影プレースホルダー対応
  - [x] 進捗バー表示
  - [x] 今日のノルマ表示
- [x] `app/assets/stylesheets/books.css` を新規作成
  - [x] .book-list グリッドレイアウト
  - [x] .book-card スタイル（hover エフェクト含む）
  - [x] .book-card__cover 画像スタイル
  - [x] 賞味期限ビジュアライザー CSS（urgent-low/medium/high）
  - [x] .book-card__progress-bar スタイル
  - [x] .book-card__quota スタイル
  - [x] Empty State スタイル
  - [x] レスポンシブ対応

## フェーズ4: ログイン後リダイレクト変更

- [x] `app/controllers/users/sessions_controller.rb` の `after_sign_in_path_for` を `books_path` に変更

## フェーズ5: テスト

- [x] `spec/models/book_spec.rb` にノルマ計算・メソッドのスペックを追加
  - [x] `daily_quota` のテスト（通常、読了済み、残ページ0、残日数計算）
  - [x] `progress_percentage` のテスト
  - [x] `days_remaining` のテスト
  - [x] `deadline_urgency_class` のテスト（各urgencyクラス）
  - [x] `for_index_list` スコープのテスト（ソート順の確認）
- [x] `spec/requests/books_spec.rb` を新規作成
  - [x] 未ログイン時のリダイレクトテスト
  - [x] ログイン済み・0冊時のEmpty State表示テスト
  - [x] ログイン済み・書籍あり時の一覧表示テスト
  - [x] ログイン後のリダイレクト先テスト (books_path)

## フェーズ6: テスト実行・品質確認

- [x] `bundle exec rspec` でテストが全通ることを確認
- [x] `bundle exec rubocop` でリントエラーがないことを確認
- [x] `bundle exec brakeman --no-pager` でセキュリティチェックがパスすることを確認

---

## 実装後の振り返り

### 実装完了日
2026年4月3日

### 計画と実績の差分

**計画通りに実施**:
- Book モデルへのメソッド追加（daily_quota, progress_percentage, days_remaining, deadline_urgency_class, for_index_list スコープ）
- BooksController と /books ルートの作成
- views/books/index.html.erb の作成（Empty State 含む）
- books.css の作成（賞味期限ビジュアライザー、レスポンシブ対応含む）
- ログイン後のリダイレクト先を books_path に変更
- 84件のスペックが全パス

**計画外の追記**:
- `config/locales/ja.yml` を新規作成（本来あるべきだったが未作成だった）
- `spec/requests/user_sessions_spec.rb` の既存テストを修正（books_path 変更に伴う期待値更新）
- Brakeman SQL Injection 警告を検出し、`Arel.sql` 文字列補間から `Arel::Nodes::Case` ノード API へ変更（セキュリティ強化）

### 学んだこと

1. **Brakeman の CASE WHEN 検出**: `Arel.sql("...#{...}...")` は enum の整数値でも SQL Injection として検出される。`Arel::Nodes::Case.new.when(col.eq(val)).then().else()` を使うと安全かつ Brakeman パスできる
2. **FactoryBot での重複タイトル問題**: request spec でビュー内の表示順序を `body.index()` で検証する場合、必ず一意なタイトルを設定する必要がある
3. **after_sign_in_path_for の変更は既存テストに影響**: セッション系 spec はリダイレクト先を明示的にテストしていた。新しいパスに合わせてテストの期待値も更新が必要

### 次回への改善提案

- Issue #14（書籍登録）が実装されたら、ビュー内の `aria-disabled` のボタンをリンクに変更する
- Issue #16（書籍詳細）が実装されたら、書籍カードを `link_to` でラップする
- 書影（cover_image）カラムは schema に存在しないが、実装時は ActiveStorage を使う設計が適切（将来）
