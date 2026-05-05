# タスクリスト: cover_proxy HTTPリダイレクト対応

## フェーズ1: 実装

- [x] `ALLOWED_REDIRECT_HOSTS` 定数と `MAX_REDIRECTS` 定数を `BooksController` に追加する
- [x] `fetch_with_redirects` プライベートメソッドを `BooksController` に実装する
- [x] `BooksController#cover_proxy` アクションを `fetch_with_redirects` を使う形に修正する

## フェーズ2: テスト追加

- [x] `spec/requests/cover_proxy_spec.rb` に302リダイレクト追跡のテストケースを追加する
  - [x] 1回リダイレクトで正常取得できるケース
  - [x] 許可外ドメインへのリダイレクトで403を返すケース
  - [x] 最大リダイレクト数超過で404を返すケース

## フェーズ3: 検証

- [x] `bundle exec rspec spec/requests/cover_proxy_spec.rb` で全テスト通過を確認する
- [x] `bundle exec rspec` で全テスト通過を確認する
- [x] `bundle exec rubocop` でエラーなしを確認する

## 振り返り

- 実装完了日: 2026-05-05
- 計画と実績の差分:
  - 計画通り `fetch_with_redirects` メソッドを追加し、リダイレクト追跡を実装した
  - 許可外ドメインへのリダイレクト時のステータスコードを `404` ではなく `403` にするため、
    `fetch_with_redirects` の戻り値として `:forbidden` シンボルを返す設計に変更した
- 学んだこと:
  - `Net::HTTP` はデフォルトでリダイレクトを追わないため、明示的な実装が必要
  - SSRF対策のためリダイレクト先ドメインも許可リストで制限することが重要
  - 無限リダイレクトループの防止には最大リダイレクト回数のカウントが必要
- 次回への改善提案:
  - `fetch_with_redirects` は他の用途にも使える汎用的なパターン。HTTPプロキシ系の機能が増えた場合はサービスクラスへの切り出しを検討
