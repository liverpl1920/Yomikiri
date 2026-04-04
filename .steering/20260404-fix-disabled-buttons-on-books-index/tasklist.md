# タスクリスト: Issue #84 - 積読一覧の無効ボタン修正

## 🚨 タスク完全完了の原則

**このファイルの全タスクが完了するまで作業を継続すること**

---

## フェーズ1: ビュー修正

- [x] ヘッダーの「+ 本を追加する」ボタンを `link_to` に変更
  - [x] `<button disabled>` を削除
  - [x] `<%= link_to "...", new_book_path, class: "btn btn--primary books-index__add-btn" %>` に置き換え
  - [x] 既存のコメント行を削除

- [x] Empty State の「最初の本を登録して始める」ボタンを `link_to` に変更
  - [x] `<button disabled>` を削除
  - [x] `<%= link_to "...", new_book_path, class: "btn btn--primary btn--lg" %>` に置き換え
  - [x] 既存のコメント行を削除

## フェーズ2: テスト更新・確認

- [x] リクエストスペック（`spec/requests/books_spec.rb`）の確認
  - [x] `GET /books` で 200 OK を確認するテストが存在するか確認
  - [x] `new_book_path` へのリンクが存在することを確認するテストを追加・確認

## フェーズ3: 品質チェック

- [x] RSpec を全件実行して通過を確認
  - [x] `bundle exec rspec` → 174 examples, 0 failures
- [x] RuboCop を実行してエラーがないことを確認
  - [x] `bundle exec rubocop` → 43 files inspected, no offenses detected

---

## 実装後の振り返り

### 実装完了日
2026-04-04

### 計画と実績の差分

**計画通りだった点**:
- ビューの2箇所のボタンを `link_to` に変更するだけの最小限の修正で完了
- RSpec・RuboCop ともにエラーなしで通過

**計画と異なった点**:
- 特になし

### 学んだこと
- 暫定実装として `disabled` ボタンを残す場合、関連機能が実装されたタイミングで確実に追跡できるよう Issue/TODOコメントで紐付けておくことが重要
- `link_to` を `<button>` の代替として使う際、CSSクラスを維持することでスタイルの変更なしに動作だけ修正できる

### 次回への改善提案
- E2E テスト（システムテスト）でボタンクリック→画面遷移も確認できると尚良い
