# 要求内容

## 概要

Issue #257「書影アップロード後に別書籍登録すると先行書影が消える問題の恒久対策（Active Storage永続化）」を解決するため、本番環境の Active Storage を S3 固定にし、書影表示失敗時の安全なフォールバックと再発防止テストを実装する。

## 背景

- 現在の production 設定では S3 環境変数が不足すると `:local` ストレージにフォールバックする。
- Render の永続ディスク非前提環境で `:local` 運用になると、再起動・再デプロイ時に書影ファイルが失われうる。
- 画像 URL/添付画像の取得失敗時に、UI 側で常に壊れ画像を回避する仕組みが不足している。

## 実装対象の機能

### 1. production の Active Storage を S3 固定 + fail-fast
- production 起動時に S3 必須環境変数を検証し、不足時は起動失敗にする。
- `config.active_storage.service` を production では常に `:amazon` に固定する。

### 2. 書影表示のフォールバック改善
- 添付画像/URL 画像のどちらでも読み込み失敗時にプレースホルダー表示へ切り替える。
- サーバー側で追跡可能なログ（無効 URL、取得失敗）を出力する。

### 3. 回帰テストの追加
- 2冊連続で書影アップロードしても1冊目の添付が維持されることをテスト化する。
- production の S3 設定不備を検知する起動時チェックをテスト化する。

## 受け入れ条件

### Active Storage 永続化
- [ ] production で `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` / `AWS_REGION` / `AWS_S3_BUCKET` のいずれかが欠けると起動時に例外が発生する。
- [ ] production で Active Storage は `:amazon` 固定となり、`:local` フォールバックしない。

### 書影表示フォールバック
- [ ] 書影 URL または添付画像の読み込み失敗時に壊れ画像のまま残らず、プレースホルダーが表示される。
- [ ] 画像 URL が不正なケース、外部取得失敗ケースでログを出力する。

### 回帰テスト
- [ ] 2冊連続アップロード後も1冊目の `cover_image` 添付が維持されるテストが追加される。
- [ ] S3 必須環境変数チェックのテストが追加される。
- [ ] RSpec / RuboCop が通過する。

## 成功指標

- production での Active Storage 設定ミスをデプロイ時に即検知できる。
- 書影表示が失敗しても UI 崩れや壊れ画像表示が発生しない。
- 同種障害（先行書影消失）の再発検知がテストで担保される。

## スコープ外

以下はこのフェーズでは実装しない:

- 既存 local 保存 blob の一括移行ツール実装
- 失われた画像の再アップロード導線 UI の新規追加
- Render ダッシュボード上の実際の環境変数設定作業

## 参照ドキュメント

- `docs/architecture.md` - アーキテクチャ設計書
- `docs/development-guidelines.md` - 開発ガイドライン
- `config/environments/production.rb` - 本番設定
- `app/helpers/books_helper.rb` - 書影表示ヘルパー
- `app/views/books/index.html.erb` - 一覧表示
- `app/views/books/show.html.erb` - 詳細表示
