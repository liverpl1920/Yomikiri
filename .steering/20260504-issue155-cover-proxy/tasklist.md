# タスクリスト

## 🚨 タスク完全完了の原則

**このファイルの全タスクが完了するまで作業を継続すること**

---

## フェーズ1: ルーティングとコントローラー

- [x] `config/routes.rb` に `cover_proxy` を collection アクションとして追加する
- [x] `BooksController` に `ALLOWED_COVER_HOSTS` 定数を定義する
- [x] `BooksController#cover_proxy` アクションを実装する
  - [x] URL パラメータのバリデーション（空・不正URI → 400）
  - [x] ホスト名チェック（`books.google.com` 以外 → 403）
  - [x] Net::HTTP でサーバーサイド画像取得（タイムアウト5秒）
  - [x] 成功時: 画像データと Content-Type を返す
  - [x] 失敗時（タイムアウト・非2xx）: 404 を返す

## フェーズ2: search_by_title のフォールバック実装

- [x] `search_by_title` で Google Books の `thumbnail` URL を取得する
  - [x] `info.dig("imageLinks", "thumbnail")` で取得
  - [x] `http://` を `https://` に正規化する
  - [x] OpenBD に書影がある場合は OpenBD を優先、なければ Google thumbnail を使用する

## フェーズ3: ビューのヘルパーと表示更新

- [x] `app/helpers/books_helper.rb` に `book_cover_src` ヘルパーメソッドを追加する
  - [x] `books.google.com` ホストの場合は `cover_proxy_books_path(url: ...)` を返す
  - [x] それ以外は URL をそのまま返す
  - [x] nil/空文字・不正URI の場合は nil を返す
- [x] `app/views/books/index.html.erb` の書影表示を `book_cover_src` を使って更新する
- [x] `app/views/books/show.html.erb` の書影表示を `book_cover_src` を使って更新する

## フェーズ4: テスト

- [x] `spec/requests/cover_proxy_spec.rb` を新規作成する
  - [x] 未ログイン → リダイレクト
  - [x] `books.google.com` URL で正常取得 → 200 + 画像データ
  - [x] `books.google.com` 以外のURL → 403
  - [x] 不正URL（parse失敗） → 400
  - [x] HTTP タイムアウト → 404
  - [x] HTTP レスポンスが非2xx → 404
- [x] `spec/requests/books_search_spec.rb` にタイトル検索のフォールバックケースを追加する
  - [x] OpenBD に書影なし + Google thumbnail あり → Google thumbnail URL が返る
  - [x] OpenBD に書影あり → OpenBD URL を優先する

## フェーズ5: 品質チェック

- [x] `bundle exec rubocop` を実行してエラーを修正する
- [x] `bundle exec rspec` を実行して全テストが通ることを確認する

---

## 実装後の振り返り

**実装完了日**: 2026-05-04

### 計画と実績の差分

- 計画通りに全フェーズを完了した
- `books_helper.rb` は新規ファイル作成となった（既存ファイルなし）
- フレーキーな system spec（`isbn_autofetch_spec.rb:87`）が CI で断続的に失敗するが、我々の変更とは無関係（著者フィールドの自動入力タイミング問題）

### 学んだこと

- Google Books の thumbnail URL は `http://` で返ってくるため、`https://` への正規化が必要
- Rails の `send_data` を使えばコントローラーから画像データをそのままブラウザに送信できる
- SSRF 対策として URI.parse でホスト名を検証することで許可ドメイン以外への転送を防ぐ
- OpenBD と Google Books の書影ソースを階層的にフォールバックすることで書影カバレッジが大幅に向上する

### 次回への改善提案

- フレーキーな system spec（`isbn_autofetch_spec.rb`）の安定化（`wait_for_ajax` などの適切な待機処理）
- 書影プロキシにキャッシュ機能（HTTP の `Cache-Control` ヘッダーの設定など）を追加することでパフォーマンスを改善できる
