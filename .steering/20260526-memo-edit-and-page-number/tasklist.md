# タスクリスト

## フェーズ1: 準備・DB変更

- [x] mainブランチからfeatureブランチを作成する
- [x] マイグレーションファイルを作成する（page_numberカラム追加）
- [x] マイグレーションを実行する

## フェーズ2: モデル変更

- [x] BookMemoモデルにpage_numberバリデーションを追加する
- [x] BookMemoモデルにedited?メソッドを追加する
- [x] PAGE_NUMBER_MAX_LENGTH定数を追加する

## フェーズ3: コントローラー変更

- [x] ルーティングにedit/updateを追加する
- [x] BookMemosControllerにedit/updateアクションを追加する
- [x] book_memo_paramsにpage_numberを追加する
- [x] before_action :set_book_memoにedit/updateを追加する

## フェーズ4: ビュー変更

- [x] app/views/book_memos/edit.html.erbを新規作成する
- [x] books/show.html.erbのメモフォームにpage_numberフィールドを追加する
- [x] books/show.html.erbのメモタイムラインに編集ボタンを追加する
- [x] books/show.html.erbのメモタイムラインに作成時刻・編集時刻表示を追加する
- [x] books/show.html.erbのメモタイムラインにpage_number表示を追加する

## フェーズ5: テスト追加・更新

- [x] spec/factories/book_memos.rbにpage_numberを追加する（デフォルトnil）
- [x] spec/models/book_memo_spec.rbにpage_numberバリデーションのテストを追加する
- [x] spec/models/book_memo_spec.rbにedited?メソッドのテストを追加する
- [x] spec/requests/book_memos_spec.rbにeditアクションのテストを追加する
- [x] spec/requests/book_memos_spec.rbにupdateアクションのテストを追加する
- [x] spec/requests/book_memos_spec.rbにpage_numberのテストを追加する

## フェーズ6: テスト実行・品質確認

- [x] bundle exec rspecを実行し全テストがパスすることを確認する
- [x] bundle exec rubocopを実行しエラーがないことを確認する

---

## 実装後の振り返り

### 実装完了日
2026-05-26

### 計画と実績の差分
- 計画通りに全タスクを完了
- 追加作業: 実装バリデーターの指摘により `edit.html.erb` の `<label>` タグを `f.label` ヘルパーに修正（パターン統一）
- スキップしたタスク: なし

### 学んだこと
- `edited?` メソッドの `1.second` 比較は ActiveSupport::Duration との比較として正しく動作する
- `current_user.books.find_by → @book.book_memos.find_by` の二段階認可チェックが横断アクセス防止に有効
- ERBファイルに対するRuboCopの誤検知（Lint/Syntax）は既存の既知問題であり、Rubyファイルのみを対象にすることで回避可能

### テスト結果
- RSpec: 598 examples, 0 failures
- RuboCop（Rubyファイル）: 5 files, no offenses

### 次回への改善提案
- マイグレーションの `page_number` カラムに `limit: 20` を追加してDBレベルの制約を加えることを検討（次回スキーマ変更時に合わせて実施）
- `book_memos` ファクトリに `:with_page_number` トレイトを追加することでシステムテスト等で再利用しやすくなる
- `edited?` メソッドの境界値テスト（ちょうど1秒差）を追加することでエッジケースのカバレッジが向上する

