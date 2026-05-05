# 設計: cover_proxy HTTPリダイレクト対応

## アプローチ
`BooksController#cover_proxy` アクションに、HTTPリダイレクト追跡ロジックを追加する。

## 変更ファイル
- `app/controllers/books_controller.rb` - `cover_proxy` アクションを修正
- `spec/requests/cover_proxy_spec.rb` - リダイレクトケースのテストを追加

## 実装詳細

### ALLOWED_REDIRECT_HOSTS の追加
```ruby
ALLOWED_COVER_HOSTS = %w[books.google.com].freeze
ALLOWED_REDIRECT_HOSTS = %w[books.google.com lh3.googleusercontent.com].freeze
MAX_REDIRECTS = 3
```

### cover_proxy アクション修正
`Net::HTTPRedirection` を検出し、`Location` ヘッダーのURLにリダイレクトする。
リダイレクト先は `ALLOWED_REDIRECT_HOSTS` に含まれるドメインに限定する。

```ruby
def cover_proxy
  url = params[:url].to_s
  uri = URI.parse(url)
  return head :forbidden unless ALLOWED_COVER_HOSTS.include?(uri.host)

  response = fetch_with_redirects(uri)
  return head :not_found if response.nil?

  content_type = response["content-type"] || "image/jpeg"
  send_data response.body, type: content_type, disposition: "inline"
rescue URI::InvalidURIError
  head :bad_request
rescue Net::OpenTimeout, Net::ReadTimeout
  head :not_found
rescue StandardError
  head :not_found
end

private

def fetch_with_redirects(uri, redirect_count = 0)
  return nil if redirect_count > MAX_REDIRECTS

  response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https",
                              open_timeout: 5, read_timeout: 5) do |http|
    http.get(uri.request_uri)
  end

  if response.is_a?(Net::HTTPRedirection)
    location = response["location"]
    redirect_uri = URI.parse(location)
    return nil unless ALLOWED_REDIRECT_HOSTS.include?(redirect_uri.host)
    fetch_with_redirects(redirect_uri, redirect_count + 1)
  elsif response.is_a?(Net::HTTPSuccess)
    response
  else
    nil
  end
end
```

## セキュリティ考慮事項
- 初回リクエストは `ALLOWED_COVER_HOSTS`（`books.google.com`）のみ許可
- リダイレクト先は `ALLOWED_REDIRECT_HOSTS`（`books.google.com`, `lh3.googleusercontent.com`）のみ許可
- 最大リダイレクト数 3 で無限ループを防止
- `URI::InvalidURIError` は `bad_request` で応答し、任意URIの注入を防ぐ
