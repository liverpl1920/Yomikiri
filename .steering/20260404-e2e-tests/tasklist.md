# タスクリスト: E2Eテスト（システムスペック）の導入

## 🚨 タスク完全完了の原則

**このファイルの全タスクが完了するまで作業を継続すること**

---

## フェーズ1: セットアップ

- [x] `database_cleaner-active_record` を Gemfile の test グループに追加
  - [x] `bundle install` を実行して Gemfile.lock を更新

- [x] `spec/support/capybara.rb` を作成
  - [x] デフォルトドライバを `:rack_test` に設定
  - [x] `js: true` タグ付きスペック用の headless Chrome ドライバを登録
  - [x] `Capybara.default_max_wait_time = 5` を設定

- [x] `spec/support/database_cleaner.rb` を作成
  - [x] デフォルト戦略: `:transaction`
  - [x] `js: true` スペックのみ `:truncation` に切り替え
  - [x] before/after フックを設定

- [x] `rails_helper.rb` を更新
  - [x] `require 'capybara/rspec'` を追加
  - [x] `Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }` のコメントアウトを解除
  - [x] `use_transactional_fixtures = false` に変更（DatabaseCleaner で制御）

- [x] `bundle exec rspec spec/system/` が空のディレクトリで正常終了することを確認

## フェーズ2: 認証フローのシステムスペック（rack_testドライバ）

- [x] `spec/system/auth/sign_up_spec.rb` を作成
  - [x] 正常な新規登録フロー（メール・パスワード入力 → ログイン状態確認）
  - [x] バリデーションエラー時のエラーメッセージ表示（パスワード確認不一致）

- [x] `spec/system/auth/sign_in_spec.rb` を作成
  - [x] 正常なログインフロー（books_path にリダイレクト）
  - [x] 誤ったパスワードでのエラーメッセージ表示
  - [x] ログアウトフロー（ドロップダウン → ログアウト、js: true）

- [x] `bundle exec rspec spec/system/auth/` でテストが通ることを確認

## フェーズ3: 書籍基本フローのシステムスペック（rack_test + JS）

- [x] `spec/system/books/books_crud_spec.rb` を作成
  - [x] 書籍登録フロー（フォーム入力 → 詳細画面表示）
  - [x] 書籍一覧表示（登録した書籍が一覧に表示される）
  - [x] Empty State 表示（書籍0冊時）
  - [x] 削除確認モーダルの OPEN（`js: true`）
  - [x] キャンセルでモーダルが閉じる（`js: true`）
  - [x] 削除確認後に書籍が削除・一覧画面にリダイレクト（`js: true`）

- [x] `bundle exec rspec spec/system/books/books_crud_spec.rb` でテストが通ることを確認

## フェーズ4: 進捗更新フローのシステムスペック（JS必須）

- [x] `spec/system/books/progress_update_spec.rb` を作成
  - [x] `＋`ボタンで pages_read 入力値が増加する
  - [x] `－`ボタンで pages_read 入力値が減少する（最低値1で止まる）
  - [x] 「現在ページを直接入力」ボタンで折りたたみが展開する
  - [x] 展開後に direct_page フィールドが表示される
  - [x] 今日読んだページ数を入力して進捗更新 → フラッシュメッセージ表示

- [x] `bundle exec rspec spec/system/books/progress_update_spec.rb` でテストが通ることを確認

## フェーズ5: 読了フローのシステムスペック（JS必須）

- [x] `spec/system/books/complete_spec.rb` を作成
  - [x] current_page >= target_pages の時「読了にする！」ボタンが表示される
  - [x] 読了ボタン押下 → バックエンド処理 → お祝いモーダル表示
  - [x] モーダルに書籍名が含まれる
  - [x] モーダルの「一覧に戻る」で books_path に遷移

- [x] `bundle exec rspec spec/system/books/complete_spec.rb` でテストが通ることを確認

## フェーズ6: 期限延長フローのシステムスペック（JS必須）

- [x] `spec/system/books/deadline_spec.rb` を作成
  - [x] 「期限を延長する」ボタンで延長モーダルが開く
  - [x] キャンセルでモーダルが閉じる
  - [x] 新しい期限を入力して「延長する」→ フラッシュメッセージ表示

- [x] `bundle exec rspec spec/system/books/deadline_spec.rb` でテストが通ることを確認

## フェーズ7: 品質チェックと最終確認

- [x] `bundle exec rspec spec/system/` で全システムスペックが通ることを確認（29 examples, 0 failures）
- [x] `bundle exec rspec` で既存テスト（172 examples）も含めた全テストが通ることを確認（201 examples, 0 failures）
- [x] `bundle exec rubocop spec/system/ spec/support/` でリントエラーがないことを確認（no offenses）
- [x] カバレッジが 89.93%（134/149）

---

## 実装後の振り返り

### 実装完了日
2026年4月

### 重要な発見・修正

1. **Stimulus非同期初期化問題**: `eagerLoadControllersFrom` が dynamic import() を使うため、Stimulus コントローラーは `document.readyState='complete'` 後も非同期で接続される。Selenium WebDriver（CDP）の最初のクリックはイベントハンドラーが未設定のため無効になる。**解決策**: Stimulus アクションボタンのクリックには `execute_script("...element.click()")` を使用。

2. **Warden test_mode と Selenium の競合**: `login_as` が JS テストでも機能してしまうため、同じ describe グループでの `before { login_as }` と JS テストの `sign_in_via_form` が衝突。**解決策**: `login_as` を非 JS コンテキストにのみ配置。

3. **show.html.erb のHTML構造バグ**: `div.modal.extendOverlay` の閉じタグ不足により、お祝いモーダルが非表示の延長モーダル内に誤ってネストされていた。修正済み。

4. **date input のロケール問題**: Selenium で `<input type="date">` に `fill_in` すると、ロケール依存の入力形式のため誤った日付になる。**解決策**: `execute_script("arguments[0].value = '...'", element)` で直接値をセット。

### 計画と実績の差分

**計画と異なった点**:
- （実装後に記録）

**技術的な発見**:
- （実装後に記録）

### 追加されたシステムスペック数
- システムスペック合計: （実装後に記録）
- カバレッジ変化: 89.93% → （実装後に記録）
