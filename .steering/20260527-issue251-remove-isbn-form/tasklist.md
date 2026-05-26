# タスクリスト

## 🚨 タスク完全完了の原則

このファイルの全タスクが完了するまで作業を継続すること。

## フェーズ1: UI・フロント実装

- [x] 登録フォームからISBN入力UIを削除
	- [x] `app/views/books/_form.html.erb` から ISBN入力欄・取得ボタン・補助文言・ステータス表示を削除
	- [x] 書影アップロード付近のISBN依存文言を汎用化

- [x] StimulusのISBN依存コードを整理
	- [x] `app/javascript/controllers/book_form_controller.js` の ISBN targets を削除
	- [x] ISBN専用メソッド（取得・バリデーション・ステータス更新）を削除

## フェーズ2: テスト修正

- [x] Request specを更新
	- [x] `spec/requests/books_spec.rb` のISBN入力表示テストを非表示確認に変更

- [x] System specを更新
	- [x] `spec/system/books/isbn_autofetch_spec.rb` のISBN UI依存ケースを整理
	- [x] ISBN誘導文言依存の期待値を必要に応じて更新

## フェーズ3: 品質チェックと修正

- [x] 実装検証サブエージェントを実行
	- [x] `implementation-validator` で変更ファイル一式の品質確認を実施

- [x] すべてのテストが通ることを確認
	- [x] `bundle exec rspec`

- [x] リントエラーがないことを確認
	- [x] `bundle exec rubocop`

- [x] ~~add-featureプロンプト準拠コマンドの確認~~（理由: 本リポジトリはRails + Importmap構成で`package.json`/npm scriptsが存在せず、Nodeベースのtest/lint/typecheckは技術的に実行不可。代替として`bundle exec rspec`と`bundle exec rubocop`で品質確認を実施）
	- [x] ~~`npm test`~~（理由: `Missing script: test`）
	- [x] ~~`npm run lint`~~（理由: `Missing script: lint`）
	- [x] ~~`npm run typecheck`~~（理由: `Missing script: typecheck`）

## フェーズ4: 仕上げ

- [x] tasklistの振り返りを記載
- [ ] コミット・push・PR作成・CI監視を実施

---

## 実装後の振り返り

### 実装完了日
2026-05-27

### 計画と実績の差分

- 受け入れ条件の網羅性を高めるため、編集画面でISBN UI非表示を確認するRequest specを追加した。
- add-feature既定のnpm検証は、Rails + Importmap構成で`package.json`が存在しないため実行不可だった。技術的理由を明記し、代替として`bundle exec rspec`と`bundle exec rubocop`を実行した。

### 学んだこと

- フォームUIの削除時は、Stimulus target定義と関連メソッドを同時に整理しないと未使用参照が残る。
- 受け入れ条件に画面単位の要件がある場合、新規画面だけでなく編集画面も同等のテストで担保するのが安全。

### 次回への改善提案

- add-feature用の共通検証コマンドはプロジェクト種別（Rails/Node）で分岐できるテンプレート化を検討する。
- Rack非推奨警告（`:unprocessable_entity`）は別Issueで一括置換すると将来互換性を高められる。
