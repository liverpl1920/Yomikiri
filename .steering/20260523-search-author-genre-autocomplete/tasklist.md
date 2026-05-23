# タスクリスト: ISSUE#216 検索著者名・ジャンルオートコンプリート

## フェーズ1: バックエンド実装

- [x] 1. `config/routes.rb` に `suggestions` コレクションルート追加
- [x] 2. `BooksController#suggestions` アクション実装
  - `field` パラメータバリデーション（`author` or `genre` のみ）
  - `q` パラメータで書籍データをフィルタリング
  - 最大5件までの結果をJSON返却

## フェーズ2: フロントエンド実装

- [x] 3. `search_filter_autocomplete_controller.js` 新規作成
  - `/books/suggestions` エンドポイントへのフェッチ実装
  - デバウンス、キーボードナビゲーション実装
  - 候補選択で入力フィールドに値をセット
- [x] 4. `app/views/books/index.html.erb` の著者名・ジャンルフィールドを更新
  - Stimulusコントローラーを適用するラッパーに変更
- [x] 5. `app/assets/stylesheets/books.css` にドロップダウン用CSS追加

## フェーズ3: テスト追加

- [x] 6. `spec/requests/books_spec.rb` にsuggestionsエンドポイントのテスト追加

## フェーズ4: 検証

- [x] 7. `bundle exec rspec` 実行・全テストパス確認（288 examples, 0 failures）
- [x] 8. `bundle exec rubocop` 実行・エラーなし確認
