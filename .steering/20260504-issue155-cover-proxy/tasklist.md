# タスクリスト

## 🚨 タスク完全完了の原則

**このファイルの全タスクが完了するまで作業を継続すること**

---

## フェーズ1: ルーティングとコントローラー

- [ ] `config/routes.rb` に `cover_proxy` を collection アクションとして追加する
- [ ] `BooksController` に `ALLOWED_COVER_HOSTS` 定数を定義する
- [ ] `BooksController#cover_proxy` アクションを実装する
  - [ ] URL パラメータのバリデーション（空・不正URI → 400）
  - [ ] ホスト名チェック（`books.google.com` 以外 → 403）
  - [ ] Net::HTTP でサーバーサイド画像取得（タイムアウト5秒）
  - [ ] 成功時: 画像データと Content-Type を返す
  - [ ] 失敗時（タイムアウト・非2xx）: 404 を返す

## フェーズ2: search_by_title のフォールバック実装

- [ ] `search_by_title` で Google Books の `thumbnail` URL を取得する
  - [ ] `info.dig("imageLinks", "thumbnail")` で取得
  - [ ] `http://` を `https://` に正規化する
  - [ ] OpenBD に書影がある場合は OpenBD を優先、なければ Google thumbnail を使用する

## フェーズ3: ビューのヘルパーと表示更新

- [ ] `app/helpers/books_helper.rb` に `book_cover_src` ヘルパーメソッドを追加する
  - [ ] `books.google.com` ホストの場合は `cover_proxy_books_path(url: ...)` を返す
  - [ ] それ以外は URL をそのまま返す
  - [ ] nil/空文字・不正URI の場合は nil を返す
- [ ] `app/views/books/index.html.erb` の書影表示を `book_cover_src` を使って更新する
- [ ] `app/views/books/show.html.erb` の書影表示を `book_cover_src` を使って更新する

## フェーズ4: テスト

- [ ] `spec/requests/cover_proxy_spec.rb` を新規作成する
  - [ ] 未ログイン → リダイレクト
  - [ ] `books.google.com` URL で正常取得 → 200 + 画像データ
  - [ ] `books.google.com` 以外のURL → 403
  - [ ] 不正URL（parse失敗） → 400
  - [ ] HTTP タイムアウト → 404
  - [ ] HTTP レスポンスが非2xx → 404
- [ ] `spec/requests/books_search_spec.rb` にタイトル検索のフォールバックケースを追加する
  - [ ] OpenBD に書影なし + Google thumbnail あり → Google thumbnail URL が返る
  - [ ] OpenBD に書影あり → OpenBD URL を優先する

## フェーズ5: 品質チェック

- [ ] `bundle exec rubocop` を実行してエラーを修正する
- [ ] `bundle exec rspec` を実行して全テストが通ることを確認する

---

## 実装後の振り返り

（全タスク完了後に記載）
