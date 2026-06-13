# タスクリスト

## 🚨 タスク完全完了の原則

**このファイルの全タスクが完了するまで作業を継続すること**

### 必須ルール
- **全てのタスクを`[x]`にすること**
- 「時間の都合により別タスクとして実施予定」は禁止
- 「実装が複雑すぎるため後回し」は禁止
- 未完了タスク（`[ ]`）を残したまま作業を終了しない

---

## フェーズ1: 準備と計画

- [x] 作業ブランチの作成（承認後）
  - [x] `git checkout main`
  - [x] `git pull`
  - [x] `git checkout -b feature/#357-confirm-progress`

## フェーズ2: 実装

- [x] Stimulusコントローラーの作成
  - [x] `app/javascript/controllers/confirm_progress_controller.js` を作成する
  - [x] `check` メソッドに差分計算および `confirm` メッセージの表示を実装する
- [x] ビューの修正
  - [x] `app/views/books/show.html.erb` に `confirm-progress` コントローラーを紐づける
  - [x] `direct_page` 入力フィールドにターゲットを設定する
  - [x] フォームに前回のページ数を Value として渡す

## フェーズ3: テストと検証

- [x] System Spec の追加
  - [x] `spec/system/books/progress_update_spec.rb` に JavaScript 動作用のテストケースを追加する
  - [x] テストが正常に通ることを確認する
- [x] すべてのテストが通ることを確認
  - [x] `bundle exec rspec`
- [x] リントエラーがないことを確認
  - [x] `bundle exec rubocop`

## フェーズ4: 完了処理

- [ ] コミット & プッシュ & PR作成
  - [ ] 実装内容をコミットし、プッシュしてPRを作成する
- [ ] 実装後の振り返り（このファイルの下部に記録）

---

## 実装後の振り返り

### 実装完了日
{YYYY-MM-DD}

### 計画と実績の差分

**計画と異なった点**:
- 

**新たに必要になったタスク**:
- 

**技術的理由でスキップしたタスク**（該当する場合のみ）:
- 

### 学んだこと

**技術的な学び**:
- 

**プロセス上の改善点**:
- 

### 次回への改善提案
- 
