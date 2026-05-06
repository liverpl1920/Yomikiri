# Design: Issue #166 Google Books API キー設定

## 実装アプローチ

### 1. `search_by_title` への key パラメータ追加

`ENV["GOOGLE_BOOKS_API_KEY"].presence` で値を取得し、存在する場合のみ
クエリパラメータに `key:` を追加する。
存在しない場合は現状と同じキーなし呼び出しとなり、後退なし。

```ruby
def search_by_title(title)
  uri = URI("https://www.googleapis.com/books/v1/volumes")
  params = { q: "intitle:#{title}", langRestrict: "ja", maxResults: 5 }
  api_key = ENV["GOOGLE_BOOKS_API_KEY"].presence
  params[:key] = api_key if api_key
  uri.query = URI.encode_www_form(params)
  # ...
end
```

### 2. `.env.example` への追記

既存のコメント構造に合わせ「外部API」セクションを新設して追記する。

### 3. `render.yaml` への追記

`SENDGRID_API_KEY` の下に `sync: false` エントリを2件追加する。

### 4. `.env`（ローカル実行用・gitignore済み）

実際のキー値はファイルへの書き込みではなく、ユーザーが手動でセットする。
本実装では `.env` への書き込みは行わない（セキュリティ上の理由）。

## セキュリティ方針
- 実際のキー値はコード・コミット・Issue本文に含めない
- `.env.example` にはプレースホルダー（`your_google_books_api_key_here`）のみ記載
- `render.yaml` の `sync: false` により値はダッシュボードでのみ管理

## 影響範囲
- `search_by_title` のみ変更（`search_by_isbn` は Google Books を使わないため不要）
- テスト: 既存のスタブは URL に `key=` パラメータが追加されてもマッチするよう
  WebMock の正規表現スタブ（`/www\.googleapis\.com\/books\/v1\/volumes/`）で対応済み
