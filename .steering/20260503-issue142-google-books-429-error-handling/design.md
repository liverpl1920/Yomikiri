# 設計書

## アーキテクチャ概要

MVC（Rails標準）。変更対象はコントローラー（`app/controllers/books_controller.rb`）とフロントエンドの Stimulus コントローラー（`app/javascript/controllers/book_search_controller.js`）、および request spec。

```
ブラウザ(Stimulus)
  → GET /books/search?q=<title>
      → BooksController#search
          → search_by_title(title)
              → fetch_json_with_status(url)
                  Net::HTTPTooManyRequests (429) → raise GoogleBooksRateLimitError
                  Net::HTTPServerError (5xx)     → raise GoogleBooksServerError
                  Net::HTTPSuccess (200)         → JSON.parse(body)
          → raise をキャッチして { books: [], error: <message> } を返す
  ← JSON
Stimulus コントローラー
  → error キーがあれば #error-message ターゲットに表示
```

## コンポーネント設計

### 1. BooksController（既存・変更）

**責務**:
- `fetch_json` を `fetch_json_with_status` に置き換え（または内部実装を変更）
- 429/5xx を受け取った場合に `GoogleBooksApiError` を raise する
- `search_by_title` の呼び出し元 `search` アクションでこれをキャッチし、`error` キーを含む JSON を返す

**実装の要点**:
- `fetch_json` は openBD（ISBN 検索）でも使われているため、壊さないようにする
- Google Books 専用の error class を用意するか、汎用 `ApiRateLimitError` を使う
- エラーメッセージは日本語でユーザーが理解できる文言にする（例: "検索リクエストが制限されています。しばらく時間をおいてから再度お試しください。"）

### 2. book_search_controller.js（既存・変更）

**責務**:
- `search` アクションのレスポンスに `error` キーがある場合にエラーメッセージを表示する

**実装の要点**:
- 既存の `showError` メソッドまたは同等のメカニズムを利用する
- エラー表示領域（ターゲット）が既に用意されているか確認する

## データフロー

### タイトル検索・429 ケース
```
1. ユーザーが検索欄に「リーダブルコード」を入力して検索
2. Stimulus が GET /books/search?q=リーダブルコード を送信
3. BooksController#search → search_by_title("リーダブルコード")
4. fetch_json が Google Books API から 429 を受け取る
5. GoogleBooksRateLimitError (またはカスタム例外) を raise
6. search アクションの rescue で { books: [], error: "<rate limit message>" } をレンダー
7. Stimulus がレスポンスの error キーを検出してエラーメッセージを表示
```

## エラーハンドリング戦略

### カスタムエラークラス（コントローラープライベート内で定義）

```ruby
# BooksController 内
GoogleBooksApiError = Class.new(StandardError)
```

### エラーハンドリングパターン

```ruby
def fetch_title_json(url)
  uri = URI(url)
  response = Net::HTTP.start(...) { |http| http.get(uri.request_uri) }
  case response
  when Net::HTTPSuccess
    JSON.parse(response.body)
  when Net::HTTPTooManyRequests
    raise GoogleBooksApiError, "検索リクエストが制限されています。しばらく時間をおいてから再度お試しください。"
  else
    raise GoogleBooksApiError, "書影の取得中にエラーが発生しました。"
  end
rescue Net::OpenTimeout, Net::ReadTimeout
  raise GoogleBooksApiError, "検索がタイムアウトしました。接続を確認して再度お試しください。"
end

def search
  ...
  books = isbn_query?(query) ? search_by_isbn(...) : search_by_title(query)
  render json: { books: }
rescue GoogleBooksApiError => e
  render json: { books: [], error: e.message }
rescue StandardError
  render json: { books: [], error: "検索中にエラーが発生しました" }
end
```

## テスト戦略

### Request spec（`spec/requests/books_search_spec.rb`）
- Google Books API が 429 を返した場合: `books: []` かつ `error` キーあり
- Google Books API が 503 を返した場合: 同様
- 正常ケースは既存テストで担保済み

### System spec
- 今回はスコープ外（request spec で十分）

## 実装の順序

1. `BooksController` にカスタム例外と `fetch_title_json` を追加（または `fetch_json` を分岐させる）
2. `search_by_title` で `fetch_title_json` を使うよう変更
3. `search` アクションの rescue に `GoogleBooksApiError` を追加
4. `book_search_controller.js` にエラー表示ロジックを追加（既存のエラー表示が不十分な場合）
5. request spec に 429 ケースを追加

## セキュリティ考慮事項

- Google Books API の URL パラメータはコントローラー内で構築しており、ユーザー入力は `URI.encode_www_form` でエスケープされているため XSS リスクなし
- エラーメッセージに内部スタックトレース等を含めない

## パフォーマンス考慮事項

- タイムアウト設定（open_timeout / read_timeout）は既存の 5 秒を維持
- 429 時はリトライしない（スコープ外）
