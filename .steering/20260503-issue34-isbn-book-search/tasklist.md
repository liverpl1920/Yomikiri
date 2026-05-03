# タスクリスト

## 🚨 タスク完全完了の原則

**このファイルの全タスクが完了するまで作業を継続すること**

---

## フェーズ1: 環境準備

- [x] Gemfileにwebmockを追加してbundle install
- [x] フィーチャーブランチ作成（feature/#34-isbn-book-search）

## フェーズ2: バックエンド実装

- [x] config/routes.rb に collection `get :search` を追加
- [x] BooksController に `search` アクションを実装
  - [x] ISBN判定ロジック（`\A\d{10,13}\z`）
  - [x] openBD APIプロキシ（ISBN用）
  - [x] Google Books APIプロキシ（タイトル用）
  - [x] ページ数抽出ヘルパー（onix構造から）
  - [x] ISBN抽出ヘルパー（Google Books industryIdentifiers から）

## フェーズ3: フロントエンド実装

- [x] book_search_controller.js を新規作成
  - [x] targets定義（query, status, results）
  - [x] search()メソッド
  - [x] fetchResults()メソッド（/books/searchへの非同期リクエスト）
  - [x] showSingleResult()（1件の場合フォームに直接補完）
  - [x] showCandidates()（複数件の場合リスト表示）
  - [x] selectCandidate()（候補選択でフォーム補完）
  - [x] fillForm()（フォームフィールドへの値セット）
  - [x] handleKeydown()（Enterキー対応）
- [x] app/views/books/_form.html.erb に検索セクションを追加
- [x] app/assets/stylesheets/books.css に書籍検索UIスタイルを追加

## フェーズ4: テスト実装

- [x] spec/requests/books_search_spec.rb を作成
  - [x] 未ログイン時 → 302リダイレクト
  - [x] ISBN検索 → openBDをスタブして書籍情報が返ること
  - [x] 存在しないISBN → 空配列が返ること
  - [x] タイトル検索 → Google Booksをスタブして複数候補が返ること
  - [x] クエリ空 → 空配列が返ること
- [x] spec/system/books/book_search_spec.rb を作成（js: true）
  - [x] ISBN入力 → 検索 → フォームに値が補完されること
  - [x] タイトル入力 → 検索 → 候補表示 → 選択 → フォーム補完されること

## フェーズ5: 品質チェック

- [x] bundle exec rspec が全て通ること
- [x] bundle exec rubocop が通ること

---

## 振り返り

（実装完了後に記載）
