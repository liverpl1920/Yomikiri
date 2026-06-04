# タスクリスト

## 🚨 タスク完全完了 of 原則

**このファイルの全タスクが完了するまで作業を継続すること**

---

## フェーズ1: 準備と実装

- [x] 共通 Concern の作成
  - [x] `app/controllers/concerns/progress_chart_preparable.rb` を作成する。
- [x] コントローラの修正
  - [x] `app/controllers/books_controller.rb` で `ProgressChartPreparable` を include し、重複メソッドを削除する。
  - [x] `app/controllers/book_memos_controller.rb` で `ProgressChartPreparable` を include し、重複メソッドを削除する。

## フェーズ2: テストの追加

- [x] リクエストスペックの追加・修正
  - [x] `spec/requests/books_spec.rb` にグラフ最大値の検証テストを追加する。
  - [x] `spec/requests/book_memos_spec.rb` にバリデーションエラー時のグラフデータ検証テストを追加する。

## フェーズ3: 品質チェックと検証

- [x] すべてのテストが通ることを確認
  - [x] `bundle exec rspec` を実行し、GREEN であることを確認する。
- [x] 静的解析エラーがないことを確認
  - [x] `bundle exec rubocop` を実行し、指摘がないことを確認する。

## フェーズ4: ドキュメント更新と完了報告

- [ ] 実装後の振り返り（このファイルの下部に記録）

---

## 実装後の振り返り

### 実装完了日
{YYYY-MM-DD}

### 計画と実績の差分

**計画と異なった点**:

**新たに必要になったタスク**:

### 学んだこと

**技術的な学び**:

**プロセス上の改善点**:

### 次回への改善提案
