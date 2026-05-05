# 要件定義: cover_proxy HTTPリダイレクト対応

## Issue
#158 [Bug] cover_proxy がHTTPリダイレクトを追わないため書影が表示されないケースがある

## 概要
`/books/cover_proxy` エンドポイントは `Net::HTTP` でGoogle Booksに直接リクエストするが、
`Net::HTTP` はデフォルトでHTTPリダイレクト（302等）を追わない。
Google Books thumbnail URLがリダイレクトを返す場合、`Net::HTTPSuccess` にならず
`head :not_found` になるため、書影が表示されない。

## 再現条件
- `cover_image_url` が `https://books.google.com/books/...` 形式のURLで、
  かつそのURLが302リダイレクトを返すケース

## 受け入れ条件
- リダイレクトが発生するGoogle Books URLでも書影が正しく表示される
- 許可外ドメインへのリダイレクトは `403` を返す
- RSpec / RuboCop が全通過する

## 制約
- 許可するリダイレクト先ドメイン: `books.google.com`, `lh3.googleusercontent.com`（Google系ドメイン）
- 無限ループ防止のため最大リダイレクト回数: 3回
- タイムアウト: 5秒（既存の設定を維持）
