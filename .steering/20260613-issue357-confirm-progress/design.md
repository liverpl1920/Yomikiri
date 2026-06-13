# 設計書

## アーキテクチャ概要

Rails 7.2 標準の Hotwire / Stimulus アーキテクチャに則り、進捗更新フォームの送信イベントをフックする軽量な Stimulus コントローラーを実装します。

```
[HTML View: show.html.erb (Form)]
  │
  ├─ (submit event) ──> [Stimulus Controller: confirm_progress_controller.js]
  │                        │
  │                        ├─ calculate diff (current_page - last_page)
  │                        ├─ format confirm message based on diff
  │                        └─ window.confirm(message)
  │                             │
  │                             ├─ OK (true) ────> Submit form to Rails (patch :update_progress)
  │                             └─ Cancel (false) ─> event.preventDefault() (Keep state)
```

## コンポーネント設計

### 1. 進捗更新フォーム (Views)
- **ファイル**: `app/views/books/show.html.erb`
- **変更箇所**: 現在ページの直接入力フォーム（120〜134行目）
- **変更内容**:
  - `form_with` に `data-controller="confirm-progress"`, `data-confirm-progress-last-page-value="<%= @book.current_page %>"`, `data-action="submit->confirm-progress#check"` を付与。
  - `input` タグに `data-confirm-progress-target="input"` を付与。

### 2. 進捗確認 Stimulus コントローラー (Javascript)
- **ファイル [NEW]**: `app/javascript/controllers/confirm_progress_controller.js`
- **責務**:
  - `lastPageValue`（前回の現在ページ数）と `input` ターゲット（入力された値）を読み取る。
  - `submit` 時の差分を計算し、適切な確認ダイアログの文言を選択して表示する。
  - キャンセルされた場合は `event.preventDefault()` で送信を中断する。

## データフロー

### 進捗更新の送信時
1. ユーザーがフォームに値を入力して「更新する」をクリック。
2. Stimulus の `submit` アクションがフックされ、`check` メソッドが実行される。
3. `check` 内で `currentVal - lastPageValue` を計算。
4. メッセージを構築して `window.confirm` を呼び出す。
5. キャンセルの場合は処理を終了し、OKの場合はフォームのデフォルト送信（非JSでの patch :update_progress への遷移、またはTurbo送信）が継続する。

## エラーハンドリング戦略

- 入力値が不正（数値以外など）の場合は確認メッセージを出さず、通常通り送信してRails側のバリデーションエラーに委ねます。

## テスト戦略

### ユニットテスト
- JSの動作であるため、モデルスペック等の追加はなし。

### 統合テスト (System Spec)
- **ファイル**: `spec/system/books/progress_update_spec.rb`
- **変更内容**: `js: true` を有効にした JS 環境用のテストを追加。
  - OKを選択した場合に正常に進捗が更新されること。
  - キャンセルを選択した場合に送信が中断されること。
  - 差分の正負、ゼロでのメッセージ出し分けが正しく行われること。

## ディレクトリ構造

```
app/
 ├── javascript/
 │    └── controllers/
 │         └── confirm_progress_controller.js  [NEW]
 └── views/
      └── books/
           └── show.html.erb  [MODIFY]
spec/
 └── system/
      └── books/
           └── progress_update_spec.rb  [MODIFY]
```

## 実装の順序

1. `app/javascript/controllers/confirm_progress_controller.js` を新規作成。
2. `app/views/books/show.html.erb` のフォームを修正。
3. `spec/system/books/progress_update_spec.rb` にテストケースを追加。
