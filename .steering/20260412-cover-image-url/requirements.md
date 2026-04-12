# 要求仕様書: 書影を外部URL文字列保存に戻す（Issue #114）

## 背景・目的

`docs/architecture.md` のMVP方針「外部URL文字列をそのまま保存」に反して、Active Storage + AWS S3 の設定が main にマージ済み（#25）。これにより本番環境でAWS環境変数が未設定の場合にアプリ起動失敗リスクがある（Issue #112）。

本対応では Active Storage / S3 に関する設定を除去し、`books.cover_image_url` カラムへの外部URL文字列保存に切り替える。

## 実施内容

### 1. Active Storage / AWS S3 関連の撤去

- `Gemfile` から `aws-sdk-s3` gem を削除
- `config/storage.yml` の `amazon` セクションを削除
- `config/environments/production.rb` の `config.active_storage.service = :amazon` を削除（Active Storage自体不要なのでコメントアウト or 削除）
- `config/initializers/active_storage_check.rb` を削除
- `render.yaml` から AWS環境変数（`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`, `AWS_BUCKET`）4件を削除
- `db/migrate/20260412051624_create_active_storage_tables.active_storage.rb` を削除し、Active Storageテーブルをロールバックするためのmigrationを作成

### 2. cover_image_url カラムの追加

- `books` テーブルに `cover_image_url: string, nullable` カラムを追加するmigrationを作成・実行

### 3. Bookモデルの更新

- URL形式バリデーション（`URI::DEFAULT_PARSER.make_regexp`）を追加

### 4. BooksController の更新

- `book_params` に `:cover_image_url` を追加

### 5. ビューの更新

- `_form.html.erb`：`cover_image_url` テキスト入力フィールドを追加（任意項目）
- `index.html.erb`：`cover_image_url` が存在すれば `<img>` で表示、なければプレースホルダー
- `show.html.erb`：同上

### 6. テスト

- Book モデルスペック：`cover_image_url` バリデーションテスト
- リクエストスペック：`cover_image_url` のCRUD確認

## 受け入れ条件

- [ ] AWS環境変数がなくても本番デプロイが成功する
- [ ] 積読登録フォームに「書影URL」入力欄が表示される
- [ ] 有効なURLを入力すると書影が表示される
- [ ] 無効なURLを入力するとバリデーションエラーが表示される
- [ ] URL未入力時にはプレースホルダーが表示される
- [ ] RSpec 全通過
- [ ] RuboCop エラーなし
