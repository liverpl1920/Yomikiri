# タスクリスト

## 🚨 タスク完全完了の原則

**このファイルの全タスクが完了するまで作業を継続すること**

---

## フェーズ1: 実装

- [x] `book_form_controller.js` に `clearCoverImageUrl` メソッドを追加する
- [x] `_form.html.erb` の `f.file_field :cover_image` に `data-action` を追加する

## フェーズ2: テスト

- [x] RSpec（モデル・リクエストスペック）が全通過することを確認する
- [x] RuboCop エラーがないことを確認する

## フェーズ3: 振り返り

- [x] `tasklist.md` に振り返りを記載する

---

## 実装後の振り返り

### 実装完了日
2026-05-26

### 計画と実績の差分

**計画と異なった点**:
- 計画通り。Stimulus action の追加のみで対応完了。変更ファイル2件のみ（JS + ERB）。

### 学んだこと

- Stimulusの `data-action` 属性を使うことで、jQuery等を使わずに宣言的にDOMイベントをコントローラーにバインドできる
- hidden フィールドと file_field の競合は、JavaScriptの `change` イベントで片方をクリアすることでシンプルに解消できる

### 次回への改善提案

- このようなフォーム間の状態依存は、将来的にStimulus Valuesを使って管理すると更に見通しがよくなる
- システムテスト（Capybara + Selenium）でファイルアップロードのシナリオもカバーできると理想的
