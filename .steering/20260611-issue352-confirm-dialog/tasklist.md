# タスクリスト

## 🚨 タスク完全完了の原則

**このファイルの全タスクが完了するまで作業を継続すること**

---

## フェーズ1: 実装とテスト

- [x] git ブランチの作成 (`feature/#352-confirm-dialog-on-complete`)
- [x] 詳細画面の「読了にする！」ボタンに confirm ダイアログを追加
  - [x] `app/views/books/show.html.erb` に `onclick: "return confirm(...)"` を追加
- [x] 読了フローの System Spec を修正・追加
  - [x] `spec/system/books/complete_spec.rb` を `js: true` に変更
  - [x] 既存の `click_button` 呼び出しを `accept_confirm` で囲む
  - [x] `dismiss_confirm`（キャンセル）用のテストケースを追加

## フェーズ2: 品質チェックと修正

- [x] すべてのテストが通ることを確認
  - [x] `bundle exec rspec spec/system/books/complete_spec.rb`
- [x] リントエラーがないことを確認
  - [x] `bundle exec rubocop spec/system/books/complete_spec.rb`

---

## 実装後の振り返り

### 実装完了日
2026-06-11

### 計画と実績の差分

**計画と異なった点**:
特にありません。計画通り実装を行いました。

**新たに必要になったタスク**:
- `complete_spec.rb` の実行時に `js: true` を指定する必要があったため、テスト定義ファイルをJS有効に変更しました。

### 学んだこと

**技術的な学び**:
- Turbo が明示的に無効化されているフォームやボタンに対しては、ブラウザ標準の `onclick: "return confirm(...)"` を用いるのが最も確実かつシンプルであることを再確認しました。
- RSpec の System Spec で確認ダイアログの挙動を検証する際、`accept_confirm` や `dismiss_confirm` を使用するためには `js: true` (JS対応のブラウザドライバ) の指定が不可欠であることを確認しました。
