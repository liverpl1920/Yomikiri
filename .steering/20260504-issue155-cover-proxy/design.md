# 設計書

## アーキテクチャ概要

既存の MVC アーキテクチャに沿って `BooksController` を拡張する。プロキシは新しいアクション `cover_proxy` として追加し、ルートに collection アクションとして定義する。

```
ブラウザ
  │
  ├─ GET /books/cover_proxy?url=https://books.google.com/...
  │    │
  │    └─ BooksController#cover_proxy
  │          ├─ URLバリデーション（books.google.com のみ許可）
  │          ├─ Net::HTTP で Google Books から画像取得
  │          └─ 画像データをそのままレスポンス（Content-Type維持）
  │
  └─ GET /books/search?q=タイトル
       │
       └─ BooksController#search → search_by_title
             ├─ Google Books API 呼び出し
             ├─ OpenBD で ISBN → cover URL 取得（既存）
             └─ OpenBD に書影なし → Google Books thumbnail URL をフォールバック
```

## コンポーネント設計

### 1. `BooksController#cover_proxy` アクション

**責務**:
- クエリパラメータ `url` のバリデーション（`books.google.com` のみ）
- Net::HTTP でサーバーサイドから画像を取得
- 取得した画像データとContent-Typeをそのままレスポンス

**実装の要点**:
- `before_action :authenticate_user!` は既存の設定で適用される
- URI.parse でホスト名を確認してから HTTP リクエスト（SSRF対策）
- タイムアウト: open_timeout 5秒, read_timeout 5秒
- 失敗時は `head :not_found`
- リダイレクトは追わない（Google 側がリダイレクトする場合は失敗扱い）

**SSRF対策の実装**:
```ruby
ALLOWED_COVER_HOSTS = %w[books.google.com].freeze

def cover_proxy
  url = params[:url].to_s
  uri = URI.parse(url)
  unless ALLOWED_COVER_HOSTS.include?(uri.host)
    return head :forbidden
  end
  # ... HTTP取得 ...
rescue URI::InvalidURIError
  head :bad_request
end
```

### 2. `search_by_title` の修正

**責務**:
- Google Books レスポンスから `thumbnail` URL を取得しフォールバックとして利用

**実装の要点**:
- 既存: `cover_image_url: lookup_openbd_cover_url(isbn)`
- 修正後: OpenBD で URL が取れた場合はそれを使い、空文字の場合は Google Books thumbnail を使う
- thumbnail URL は `http://` で返ることがあるため `https://` に変換する

```ruby
openbd_url = lookup_openbd_cover_url(isbn)
google_thumbnail = info.dig("imageLinks", "thumbnail").to_s.sub(/\Ahttp:/, "https:")
cover_image_url = openbd_url.present? ? openbd_url : google_thumbnail
```

### 3. ルーティング追加

```ruby
resources :books, only: [...] do
  collection do
    get :search
    get :cover_proxy  # 追加
  end
  ...
end
```

### 4. ビューの書影表示ヘルパー

**方針**: ビューにロジックを書かず、helper メソッドで `cover_src` を返す。

```ruby
# app/helpers/books_helper.rb
def book_cover_src(cover_image_url)
  return nil if cover_image_url.blank?

  if URI.parse(cover_image_url).host == "books.google.com"
    cover_proxy_books_path(url: cover_image_url)
  else
    cover_image_url
  end
rescue URI::InvalidURIError
  nil
end
```

ビューでは:
```erb
<% src = book_cover_src(book.cover_image_url) %>
<% if src %>
  <img src="<%= src %>" ...>
<% else %>
  <span ...>📖</span>
<% end %>
```

## データフロー

### タイトル検索 → 書籍登録 → 書影表示

```
1. ユーザーがタイトル入力
2. GET /books/search?q=タイトル
3. Google Books API 呼び出し → volumeInfo取得
4. ISBN-13 を抽出して OpenBD で書影URL取得
5. OpenBD に書影なし → Google Books thumbnail URL を使用（http→https変換）
6. JSON レスポンスに cover_image_url として返す
7. Stimulus JS が hidden_field に cover_image_url をセット
8. フォーム送信 → DB に cover_image_url 保存（Google Books URL のまま）
9. 一覧・詳細画面表示時:
   - cover_image_url が books.google.com のホスト → /books/cover_proxy?url=... 経由
   - cover.openbd.jp のホスト → そのまま <img src="...">
10. /books/cover_proxy がサーバーサイドで画像取得してブラウザに返す
```

## エラーハンドリング戦略

| 状況 | レスポンス |
|------|-----------|
| `url` パラメータなし | head :bad_request |
| `books.google.com` 以外のホスト | head :forbidden |
| 不正なURL（parse失敗） | head :bad_request |
| HTTP タイムアウト | head :not_found |
| HTTP レスポンスが 2xx 以外 | head :not_found |

## テスト戦略

### request spec: `spec/requests/cover_proxy_spec.rb`

- 未ログイン → リダイレクト
- `books.google.com` URL で正常取得 → 200 + 画像データ
- `books.google.com` 以外のURL → 403
- 不正URL → 400
- タイムアウト → 404
- 画像取得失敗（4xx/5xx） → 404

### 既存テストの修正

- `spec/requests/books_search_spec.rb`: タイトル検索でOpenBDに書影がない場合にGoogle thumbnailを返すケースを追加
