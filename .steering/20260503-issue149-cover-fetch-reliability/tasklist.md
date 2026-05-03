# タスクリスト

## フェーズ1: コア実装
- [x] タイトル検索の書影URL決定ロジックを openBD 優先に変更
  - [x] `app/controllers/books_controller.rb` の `search_by_title` を更新
  - [x] openBD照会ヘルパーメソッドを追加

- [x] 送信前自動取得ガードを追加
  - [x] `app/views/books/_form.html.erb` に submit action を追加
  - [x] `app/javascript/controllers/book_form_controller.js` に submit前待機ロジックを追加

## フェーズ2: テスト更新
- [x] request spec を新仕様に合わせる
  - [x] `spec/requests/books_search_spec.rb` の期待値とstubを更新

- [x] system spec を新仕様に合わせる
  - [x] `spec/system/books/isbn_autofetch_spec.rb` の期待値を更新
  - [x] 429時ISBN補完ケースを追加
  - [x] 入力後即送信ケースを追加

## フェーズ3: 検証
- [x] `bundle exec rspec spec/requests/books_search_spec.rb spec/system/books/isbn_autofetch_spec.rb`
- [x] `bundle exec rubocop`

## フェーズ4: 仕上げ
- [ ] tasklist振り返りを記載
- [ ] 変更をコミット
- [ ] push & PR作成
- [ ] `gh pr checks --watch` を実行

---

## 実装後の振り返り

### 実装完了日

### 計画と実績の差分

### 学んだこと

### 次回への改善提案
