# 設計書

## アーキテクチャ概要
積読本詳細画面の「読了にする！」ボタン（同期的なPATCH送信）に対して、HTML5標準の確認ダイアログ（`onclick: "return confirm(...)"`）を適用します。
これにより、JavaScript側の複雑な制御やTurboの非同期通信のライフサイクルに依存せず、確実に送信を制御します。

## コンポーネント設計

### 1. 積読本詳細画面 (Views)
- **ファイル**: `app/views/books/show.html.erb`
- **変更箇所**: `button_to '読了にする！'`
- **変更内容**: HTMLオプションとして `onclick: "return confirm('本当に読了にしますか？')"` を追加。

## テスト戦略

### ユニットテスト
- 既存のモデル等のロジックには影響しないため追加なし。

### 統合テスト (System Spec)
- **ファイル**: `spec/system/books/complete_spec.rb`
- **テスト内容**:
  - `accept_confirm` でボタン押下を行い、読了お祝いモーダルが表示されることを検証。
  - `dismiss_confirm` でボタン押下を行い、画面やステータスが維持されることを検証。
- **設定変更**: System Spec の describe に `js: true` を指定し、JS対応ドライバ（`headless_chrome`）で動作させます。
