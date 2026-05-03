# 要求内容

## 概要

Google Books の thumbnail URL を Rails サーバー側でプロキシ取得して書影を表示する機能を実装する。現在 OpenBD に書影がない書籍は書影なし（📖）表示になっているが、Google Books 経由で書影を表示できるようにする。

## 背景

- `search_by_title` は現在 Google Books API で取得した ISBN を使って OpenBD から書影URL（`cover.openbd.jp`）を生成している
- しかし OpenBD の書影カバレッジは低く、多くの書籍で `cover_image_url` が空文字 `""` になっている
- Google Books API は `volumeInfo.imageLinks.thumbnail` として書影URLを持っているが、現在の実装ではこのURLを取得・保存していない
- Google Books の thumbnail URL を `<img>` タグで直接表示しようとすると、CORSやリファラーチェックにより画像が表示されないケースがある

## 実装対象の機能

### 1. Google Books thumbnail URL のフォールバック取得

- `search_by_title` メソッドで Google Books API の `volumeInfo.imageLinks.thumbnail` も取得する
- OpenBD で書影が取得できない場合のフォールバックとして Google Books thumbnail URL を使用する
- `cover_image_url` フィールドに Google Books thumbnail URL をそのまま保存する

### 2. `/books/cover_proxy?url=...` プロキシエンドポイント

- `BooksController` に `cover_proxy` アクションを追加する
- パラメータで受け取った URL に対してサーバーサイドで HTTP リクエストを行い、画像データをブラウザに返す
- 許可ドメインを `books.google.com` のみに限定してSSRF攻撃を防ぐ
- タイムアウト5秒を設ける
- 画像取得失敗時は404を返す

### 3. ビューの書影表示更新

- 一覧画面（index.html.erb）と詳細画面（show.html.erb）で `cover_image_url` が `books.google.com` ドメインの場合は `/books/cover_proxy?url=...` 経由で表示する
- OpenBD URL（`cover.openbd.jp`）はそのまま `<img src="...">` で表示する

## 受け入れ条件

### エンドポイント
- [ ] `/books/cover_proxy?url=...` エンドポイントが実装されている
- [ ] `books.google.com` 以外のドメインへのリクエストは403を返す
- [ ] 画像取得失敗・タイムアウトは404を返す
- [ ] ログイン済みユーザーのみアクセス可能

### 書影表示
- [ ] タイトル検索後に書籍を登録すると、一覧・詳細画面で書影が正しく表示される
- [ ] OpenBD に書影がある場合は OpenBD URL を優先する
- [ ] OpenBD に書影がなく Google Books に thumbnail がある場合はプロキシ経由で表示される
- [ ] 画像取得に失敗した場合はプレースホルダー（📖）が表示される

### テスト・品質
- [ ] RSpec が全通過する
- [ ] RuboCop がエラーなし

## スコープ外

- OpenBD 以外の画像プロキシ対応（Amazon など）
- 書影のキャッシュ機能
- 書影アップロード機能

## 参照ドキュメント

- `docs/architecture.md` - アーキテクチャ設計書
- `docs/development-guidelines.md` - 開発ガイドライン
