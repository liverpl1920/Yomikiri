# タスクリスト

## 🚨 タスク完全完了の原則

このファイルの全タスクが完了するまで作業を継続すること。

## フェーズ1: 入力UIと登録フロー整備

- [x] 書籍登録フォームで既読ページ入力を受け付ける
	- [x] `app/views/books/_form.html.erb` の hidden `current_page` を任意入力欄に置き換える
	- [x] 入力欄のエラー表示を既存フォームパターンに合わせる
	- [x] タイトル/ISBN自動入力後も入力値が保持されることを確認する

- [x] 作成時の `current_page` 未入力を 0 として扱う
	- [x] `BooksController` の `book_params` 受け取り時に空文字を 0 補完する
	- [x] 既存の create 成功/失敗フローを維持する

## フェーズ2: バリデーションとメッセージ

- [x] `current_page` の上限チェックを明確化する
	- [x] `Book` モデルに `current_page <= total_pages` バリデーションを追加する
	- [x] 既存 `current_page <= target_pages` と重複しない文言でエラー表示されるようにする
	- [x] 日本語翻訳メッセージを `config/locales/ja.yml` に追加する

## フェーズ3: テスト追加・更新

- [x] request spec で登録パターンを拡充する
	- [x] `current_page` 未入力で 0 保存されるケースを追加
	- [x] `current_page` 入力値が保存されるケースを追加
	- [x] `current_page` 負数/`target_pages` 超過/`total_pages` 超過の異常系を追加

- [x] model spec で境界値を補強する
	- [x] `current_page > total_pages` が無効であることを追加
	- [x] エラーメッセージキーが期待どおり付与されることを追加

## フェーズ4: 品質チェックと振り返り

- [x] 実装品質をサブエージェントで検証する
	- [x] `implementation-validator` で変更差分レビューを実施する

- [x] 自動テストと静的解析を実行する
	- [x] `bundle exec rspec`
	- [x] `bundle exec rubocop`
	- [x] ~~`npm test`~~（理由: 本リポジトリはRails+Importmap構成で `package.json` に `test` スクリプトが定義されていないため実行対象外）
	- [x] ~~`npm run lint`~~（理由: 本リポジトリはRails+Importmap構成で `package.json` に `lint` スクリプトが定義されていないため実行対象外）
	- [x] ~~`npm run typecheck`~~（理由: 本リポジトリはRails+Importmap構成で `package.json` に `typecheck` スクリプトが定義されていないため実行対象外）

- [x] 実装後の振り返りを記載する
	- [x] 実装完了日・差分・学び・改善提案を更新する

---

## 実装後の振り返り

### 実装完了日
2026-05-17

### 計画と実績の差分

- 計画時点では request/model spec の更新を中心に想定していたが、実装検証で指摘された回帰リスクを抑えるため system spec（タイトル自動取得後の既読ページ保持）を追加した。
- テストコマンドはプロンプト指定の npm 系を実行したが、Rails + Importmap 構成により該当スクリプト未定義のため技術的理由付きでスキップ記録した。

### 学んだこと

- `current_page` を任意入力化する場合、フォーム側だけでなく controller で blank を 0 補完すると後方互換を壊さず移行できる。
- `current_page <= target_pages` と `current_page <= total_pages` は実運用上重なり得るため、エラーキーを分離してテストで担保すると意図したメッセージを維持しやすい。
- 自動入力UIの維持要件は request spec だけでは不十分で、Stimulus挙動を system spec で押さえる必要がある。

### 次回への改善提案

- `have_http_status(:unprocessable_entity)` の Rack 非推奨警告を解消するため、段階的に `:unprocessable_content` へ置換する。
- フォーム関連の回帰防止として、書籍登録画面の主要UI（任意入力・自動取得・バリデーション表示）を system spec で一貫して管理する。
