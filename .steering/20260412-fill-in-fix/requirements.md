# 要求内容

## 概要

CI で不安定に失敗する期限延長システムスペックを安定化するため、`spec/system/books/deadline_spec.rb` の日付入力方法を `execute_script` から `fill_in` に変更する。

## 背景

PR #116 で `spec/system/books/deadline_spec.rb` の「新しい期限を入力して延長するとフラッシュメッセージが表示される」が CI で断続的に失敗した。`type="date"` への JS 直接代入は headless Chrome で不安定になりやすく、フォーム送信が発火しないケースがある。

## 実装対象の機能

### 1. 期限延長システムスペックの安定化
- 日付入力を `fill_in` に統一する
- 既存の期待値（フラッシュ表示）を維持する

### 2. 回帰防止の検証
- 対象スペックをローカルで実行し、成功を確認する
- RuboCop でスタイル規約に問題がないことを確認する

## 受け入れ条件

### 期限延長システムスペックの安定化
- [ ] `spec/system/books/deadline_spec.rb` で `execute_script` による date 値代入が削除されている
- [ ] `fill_in 'deadline', with: new_deadline` で値入力している
- [ ] テストが引き続き `読了期限を延長しました` を検証している

### 回帰防止の検証
- [ ] `bundle exec rspec spec/system/books/deadline_spec.rb` が成功する
- [ ] `bundle exec rubocop spec/system/books/deadline_spec.rb` が成功する

## 成功指標

- 対象スペックがローカルで再実行可能な状態で安定して通過する
- CI の同等条件で flaky 要因を1つ除去できる

## スコープ外

以下はこのフェーズでは実装しません:

- 期限延長機能本体（コントローラー・モデル）の仕様変更
- 他のシステムスペックの全面リライト
- CI ワークフロー自体の変更

## 参照ドキュメント

- `docs/architecture.md` - MVC / Hotwire 構成
- `docs/development-guidelines.md` - テスト実装規約
