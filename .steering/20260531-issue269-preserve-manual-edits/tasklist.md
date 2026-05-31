# タスクリスト

## 🚨 タスク完全完了の原則

**このファイルの全タスクが完了するまで作業を継続すること**

---

## フェーズ1: 実装

- [x] `book_form_controller.js` の `_fillFormFromSearch` を修正
  - [x] `author` フィールド: 空の場合のみ自動入力に変更
  - [x] `genre` フィールド: 空の場合のみ自動入力に変更
  - [x] `total_pages` フィールド: 空の場合のみ自動入力に変更

## フェーズ2: テスト追加

- [x] `spec/system/books/book_form_feedback_spec.rb` に既存テストを確認
- [x] ジャンル手動入力後にautoFetchされても保持されることを確認するテスト追加
- [x] 総ページ数手動入力後にautoFetchされても保持されることを確認するテスト追加
- [x] フィールドが空の場合はAPIの値で自動入力されることを確認するテスト追加

## フェーズ3: 品質チェック

- [x] `bundle exec rspec spec/system/books/book_form_feedback_spec.rb` でテストがパスすることを確認
- [x] `bundle exec rubocop` でリントエラーがないことを確認

---

## 実装後の振り返り

### 実装完了日
{未入力}

### 計画と実績の差分
{未入力}

### 学んだこと
{未入力}

### 次回への改善提案
{未入力}
