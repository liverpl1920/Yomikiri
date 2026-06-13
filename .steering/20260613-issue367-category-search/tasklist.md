# タスクリスト

## 🚨 タスク完全完了の原則

**このファイルの全タスクが完了するまで作業を継続すること**

### 必須ルール
- **全てのタスクを`[x]`にすること**
- 「時間の都合により別タスクとして実施予定」は禁止
- 「実装が複雑すぎるため後回し」は禁止
- 未完了タスク（`[ ]`）を残したまま作業を終了しない

---

## フェーズ1: 準備とブランチ作成

- [ ] Gitブランチを作成する
  - [ ] `main` ブランチに切り替え、最新をプルする
  - [ ] `feature/#367-category-search` ブランチを作成・切り替える

## フェーズ2: モデルの実装

- [ ] `Book` モデルに `categories_i18n` クラスメソッドを追加する (`app/models/book.rb`)
- [ ] `Book.filtered_for_index` に `category` による絞り込み処理を追加する (`app/models/book.rb`)

## フェーズ3: コントローラーの実装

- [ ] `BooksController#normalized_index_search_params` に `category` の許可と安全な抽出を追加する (`app/controllers/books_controller.rb`)
- [ ] `BooksController#index` 内の `book_search_keys` 配列に `:category` を追加する (`app/controllers/books_controller.rb`)

## フェーズ4: ビューの実装

- [ ] `books/index.html.erb` に「書籍の種類」セレクトボックスを実装する
  - [ ] `select_tag` を用いて、`Book.categories_i18n` から選択肢を生成する
  - [ ] デフォルトとして `include_blank: "すべての種類"` を指定する
  - [ ] `@search_params[:category]` を用いて、検索後も選択状態を保持する

## フェーズ5: テストの実装と実行

- [ ] `spec/requests/books_index_spec.rb` にテストケースを追加する
  - [ ] `category` が異なる本を作成し、特定の種類で絞り込んで正しく結果が得られることをテストする
  - [ ] 未選択（「すべての種類」）の際、絞り込みが行われずすべての本が得られることをテストする
  - [ ] 検索実行後、レスポンスHTML内のセレクトボックスで選択したカテゴリが選択状態（`selected="selected"`）になっていることをテストする

## フェーズ6: 品質チェックと修正

- [ ] すべてのテストが通ることを確認
  - [ ] `bundle exec rspec spec/requests/books_index_spec.rb`
  - [ ] `bundle exec rspec` (必要に応じて全体実行)
- [ ] リントエラーがないことを確認
  - [ ] `bundle exec rubocop`

## フェーズ7: コミットとプッシュ

- [ ] 変更内容をコミットする
  - [ ] コミットメッセージ規約に従い、Issue番号（`#367`）を含める
- [ ] プッシュする
- [ ] プルリクエストを作成する (GitHub CLIを使用)

## フェーズ8: ドキュメント更新

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
  - スキップ理由: 
  - 代替実装: 

### 学んだこと

**技術的な学び**:
- 

**プロセス上の改善点**:
- 

### 次回への改善提案
- 
