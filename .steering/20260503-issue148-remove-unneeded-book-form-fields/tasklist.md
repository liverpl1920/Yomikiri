# タスクリスト

## 🚨 タスク完全完了の原則

**このファイルの全タスクが完了するまで作業を継続すること**

### 必須ルール
- **全てのタスクを`[x]`にすること**
- 未完了タスク（`[ ]`）を残したまま作業を終了しない

---

## フェーズ1: UIとフロントロジック整理

- [x] 登録フォームの不要入力欄を削除
	- [x] `app/views/books/_form.html.erb` から「ISBNまたは書籍名から自動入力」セクションを削除
	- [x] `app/views/books/_form.html.erb` から「書影URL」入力欄を削除

- [x] StimulusコントローラーからISBNフォールバック導線を削除
	- [x] `book_form_controller.js` の `isbnSection/isbn/isbnStatus` ターゲットを削除
	- [x] `fetchByIsbn`, `_showIsbnFallback`, `_hideIsbnSection`, `_setIsbnStatus` を削除
	- [x] 取得失敗時のメッセージをタイトルステータス表示のみへ整理

- [x] 不要CSSを削除
	- [x] `books.css` の `.book-search*` 関連スタイルを削除
	- [x] `books.css` の `.book-form__isbn-section*` 関連スタイルを削除

## フェーズ2: テスト更新

- [x] 削除対象UIに依存する system spec を整理
	- [x] `spec/system/books/book_search_spec.rb` を削除

- [x] タイトル自動取得 system spec を新UIに合わせて更新
	- [x] 「書影URL」「ISBNフォールバック表示」の期待値を削除
	- [x] 不要欄が表示されないことを検証追加
	- [x] タイトル起点の成功/失敗メッセージ検証を維持

## フェーズ3: 品質チェック

- [x] テストを実行し成功を確認
	- [x] `bundle exec rspec spec/system/books/isbn_autofetch_spec.rb spec/requests/books_search_spec.rb`

- [x] Lintを実行し成功を確認
	- [x] `bundle exec rubocop`

## フェーズ4: 仕上げ

- [ ] 変更差分を確認し、コミットを作成
- [ ] ブランチをpushし、PRを作成
- [ ] CI結果を確認
- [ ] 実装後の振り返りを記載

---

## 実装後の振り返り

### 実装完了日

### 計画と実績の差分

### 学んだこと

### 次回への改善提案
