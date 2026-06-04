# タスクリスト

## 🚨 タスク完全完了の原則
**このファイルの全タスクが完了するまで作業を継続すること**

## フェーズ1: 準備とDBマイグレーション
- [x] 1. 新しいブランチを作成する (`feature/#267-268-275-280-book-enhancements`)
- [x] 2. データベースマイグレーションファイルを作成し、`books` テーブルを修正する
  - `total_pages` から `pages` へのリネーム
  - 既存データで `target_pages` の値がある場合 `pages` を更新
  - `target_pages` の削除
  - `translator` (string) と `publisher` (string) の追加
- [x] 3. `bin/rails db:migrate` および `bin/rails db:test:prepare` を実行する

## フェーズ2: モデルの修正とテスト
- [x] 4. `Book` モデル (`app/models/book.rb`) を修正する
  - `total_pages` と `target_pages` のバリデーションの削除、`pages` のバリデーション追加
  - 進捗計算ロジック（`remaining_pages`, `daily_quota`, `progress_percentage` 等）で `pages` を使用するように変更
  - `publisher_like` スコープの追加と `filtered_for_index` の修正
- [x] 5. モデルテスト (`spec/models/book_spec.rb` と `spec/models/user_spec.rb`) を修正し、テストが通過することを確認する

## フェーズ3: コントローラの修正
- [x] 6. `BooksController` (`app/controllers/books_controller.rb`) を修正する
  - `book_params` と `edit_book_params` のパラメータ修正（`total_pages`, `target_pages` 排除、`pages`, `translator`, `publisher` 許可）
  - `search_by_isbn` と `search_by_title` で `pages`, `translator`, `publisher` を取得して返すように変更
  - 検索パラメータに `publisher` を追加

## フェーズ4: フロントエンドとビューの修正
- [x] 7. Stimulus コントローラ (`app/javascript/controllers/book_form_controller.js`) を修正する
  - `syncTargetPages` を削除
  - `pages` ターゲットでの `calculateQuota` 計算への書き換え
  - 検索自動補完結果の `translator`、`publisher` 反映処理追加
- [x] 8. 書籍フォーム (`app/views/books/_form.html.erb`) を修正する
  - 「ページ数」1項目に統合
  - 「翻訳者」「出版社」の入力フィールドを追加
- [x] 9. 書籍詳細画面 (`app/views/books/show.html.erb`) を修正する
  - 「ページ数」、「翻訳者」、「出版社」を表示する
  - 進捗表示などの記述を「ページ数」に合わせる
- [x] 10. 書籍一覧・検索画面 (`app/views/books/index.html.erb`) を修正する
  - 検索フォームに出版社検索を追加
  - 一覧カードおよび詳細テーブルでの翻訳者・出版社・ページ数表示を修正
- [x] 11. ローカライズファイル (`config/locales/ja.yml`) を更新する
  - `pages`、`translator`、`publisher` の日本語訳追加

## フェーズ5: テスト修正と品質検証
- [x] 12. 既存のスペック（システムテスト、リクエストテスト等）を全て修正・実行し、リント・テストが正常に通過することを確認する
  - `bundle exec rspec`
  - `bundle exec rubocop`

## フェーズ6: 振り返り
- [x] 13. タスクリストの振り返りセクションを更新する

---
## 実装後の振り返り
### 実装完了日
2026-06-05

### 計画と実績の差分
- フロントエンドにおける「ページ数」と「既に読んだページ数」のラベルの部分一致によるCapybaraのアサーション曖昧さ（Ambiguous match）が発生したため、アサーションに `exact: true` を指定する修正を追加。
- 合わせて、高負荷時のSeleniumによるキー入力の遅延・消失を防ぐため、一部の数値入力テストケースで JS を用いて値を直接設定する形へ修正した。
- その他、以前の `target_pages` などのテスト内での記述残りなどを一掃。結果として、622個のテストすべてとRuboCopが正常にパスした。
