# タスクリスト: メモタイムライン機能実装 (ISSUE#239)

## フェーズ1: データベース・モデル

- [x] マイグレーションファイルを作成する（`book_memos` テーブル）
- [x] マイグレーションを実行してDBスキーマを更新する
- [x] `BookMemo` モデルを作成する（バリデーション・アソシエーション含む）
- [x] `Book` モデルに `has_many :book_memos` を追加する
- [x] `spec/factories/book_memos.rb` ファクトリを作成する

## フェーズ2: コントローラー・ルーティング

- [x] `BookMemosController` を作成する（create, destroy アクション）
- [x] ルーティングを追加する（books リソース下にネスト）

## フェーズ3: ビュー

- [x] `show.html.erb` のメモセクションをタイムライン形式に書き換える
- [x] メモ追加フォームを実装する
- [x] タイムライン一覧（新しい順）を実装する（件数0件の案内メッセージ含む）
- [x] 各メモの削除ボタンを実装する
- [x] `_form.html.erb` から既存 memo フォームフィールドを非表示にする（保持はする）

## フェーズ4: テスト

- [x] `spec/models/book_memo_spec.rb` を作成する
- [x] `spec/requests/book_memos_spec.rb` を作成する（create, destroy, 認可テスト）

## フェーズ5: 最終確認

- [ ] `bundle exec rspec` を実行し全テスト通過を確認する
- [ ] `bundle exec rubocop` を実行しエラーなしを確認する

---

## 振り返り（実装完了後に記載）
