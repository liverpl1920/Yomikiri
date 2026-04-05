# 要求内容: E2Eテスト（システムスペック）の導入

## 概要

Capybara + Selenium（headless Chrome）を使ったE2Eテスト（RSpec system specs）を導入し、
JavaScriptが絡む実際のユーザーフローを自動テストで保護する。

## 背景

現在のテスト構成は以下の通り:

| 種別 | ファイル | テスト数 |
|------|---------|---------|
| モデルスペック | spec/models/book_spec.rb | ~60 |
| モデルスペック | spec/models/user_spec.rb | 5 |
| リクエストスペック | spec/requests/books_spec.rb | ~90 |
| リクエストスペック | spec/requests/user_sessions_spec.rb | ~15 |
| リクエストスペック | spec/requests/header_footer_spec.rb | ~8 |
| **合計** | | **172 examples, 0 failures** |
| **カバレッジ** | | **89.93% (134/149行)** |
| **E2Eスペック** | | **0（未導入）** |

### 問題点

リクエストスペックは HTTP レベルの検証（ステータスコード・HTML 文字列）が中心で、
以下の JavaScript インタラクションは一切テストされていない:

1. **Stimulus コントローラー** (`app/javascript/controllers/`)
   - `modal_controller.js`: 削除確認モーダル・期限延長モーダルの開閉
   - `progress_update_controller.js`: ±ボタン・詳細入力トグル
   - `dropdown_controller.js`: ヘッダードロップダウン
   - `google_calendar_controller.js`: Google Calendar リンク生成
   - `book_form_controller.js`: 登録フォームの動態計算

2. **ユーザーフロー全体の連結**
   - 新規登録 → ログイン → 書籍追加 → 進捗更新 → 読了 等の連結した操作

### Gemfile 確認済み

`capybara` と `selenium-webdriver` は既に test グループに追加済み:

```ruby
gem "capybara"
gem "selenium-webdriver"
```

ただし `rails_helper.rb` にシステムスペック用の設定が未追加。

## 実装対象の機能

### 1. E2Eテスト基盤のセットアップ

- `rails_helper.rb` に Capybara/システムスペック設定を追加
- `spec/support/capybara.rb` を作成してドライバ設定を集約
- `spec/system/` ディレクトリを作成してシステムスペックを格納

### 2. 認証フローのシステムスペック

**対象**: Issue #5, #6, #7（新規登録・ログイン・ログアウト）

- 新規ユーザー登録フロー（メール入力・パスワード入力・登録完了）
- ログインフロー（正常系・エラー表示確認）
- ログアウトフロー（ドロップダウン → ログアウト）

### 3. 書籍管理フローのシステムスペック

**対象**: Issue #10, #11, #12, #13（登録・一覧・詳細・削除）

- 書籍登録フォームの操作（フォーム入力・バリデーションエラー表示）
- 一覧画面の書籍カード表示・urgencyクラス確認
- 削除確認モーダルの開閉・削除実行

### 4. 進捗更新・読了フローのシステムスペック

**対象**: Issue #15, #17（進捗更新・読了）

- ±ボタンによる pages_read の増減
- 「現在ページを直接入力」折りたたみ表示トグル
- 読了ボタン押下 → お祝いモーダル表示

### 5. 期限延長フローのシステムスペック

**対象**: Issue #18（期限延長）

- 「期限を延長する」ボタン → 延長モーダル表示
- 日付選択 → 延長実行 → フラッシュメッセージ確認

## 受け入れ条件

### セットアップ
- [ ] `bundle exec rspec spec/system/` でシステムスペックが実行できる
- [ ] headless Chrome ドライバが使用できる（CI との互換性）
- [ ] JS不要なスペックには `:rack_test`、JS必要なスペックには `:selenium_chrome_headless` ドライバが使われる

### 認証フロー
- [ ] 新規登録フォームに入力してユーザー登録ができる
- [ ] ログインフォームで正常ログインできる
- [ ] ログアウトリンクからログアウトできる

### 書籍管理フロー
- [ ] 書籍登録フォームに入力して書籍が作成される
- [ ] 書籍一覧に登録した書籍が表示される
- [ ] 削除確認モーダルが開閉する
- [ ] 削除確認後に書籍が削除される

### 進捗更新フロー
- [ ] ±ボタンで pages_read 入力値が増減する
- [ ] 「現在ページを直接入力」セクションが折りたたみで開閉する
- [ ] 読了後にお祝いモーダルが表示される

### 期限延長フロー
- [ ] 期限延長モーダルが開閉する
- [ ] 新しい期限日を入力して延長が完了する

## 成功指標

- 全 system spec が `bundle exec rspec spec/system/` で通過する
- JS インタラクションをカバーするシステムスペックが 30 example 以上追加される
- 全体のカバレッジが 90% 以上を維持する

## スコープ外

以下はこのフェーズでは実装しません:

- Visual regression テスト（スクリーンショット比較）
- パフォーマンステスト
- Issue #21 以降（Active Storage, マイページ等）の機能のE2Eテスト
- Googleカレンダー連携の実際の外部API呼び出し（URLのみ検証）

## 参照ドキュメント

- `docs/functional-design.md` - 機能設計書
- `docs/development-guidelines.md` - 開発ガイドライン
- `issue/ISSUE.md` - 各 Issue の実装内容・完了条件
