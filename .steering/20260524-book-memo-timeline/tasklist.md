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

- [x] `bundle exec rspec` を実行し全テスト通過を確認する（564 examples, 0 failures）
- [x] `bundle exec rubocop` を実行しエラーなしを確認する

## フェーズ6: コミット・PR

- [x] コミット: `#239 メモタイムライン機能の実装`
- [x] ブランチ push: `feature/#239-book-memo-timeline`
- [x] PR 作成: #240
- [x] CI 確認: RuboCop & Brakeman & bundler-audit PASS、RSpec PASS

---

## 振り返り（実装完了後に記載）

### うまくいったこと
- `BookMemo` モデル・コントローラー・ルーティング・ビューの一連の実装がスムーズに完了した
- `prepare_show_vars` プライベートメソッドを追加し、`render :show` を呼ぶ全エラーパスを網羅できた
- テスト設計が明確で、モデル・リクエスト・システムテストの各レイヤーをカバーできた

### 苦労した点
- **BooksController 回帰22件**: `render :show` 時に `@book_memos` / `@new_book_memo` が未設定でエラー。`prepare_show_vars` の追加と全エラーパスへの呼び出しで解消
- **isbn_autofetch_spec の不安定テスト (line 116)**: `fill_in`（Selenium フォーカス管理）+ `execute_script dispatchEvent blur` の組み合わせがフルスイート時に競合。`currentPage` の設定も `execute_script` に統一し、Selenium フォーカス状態の干渉を除去して解消

### 学び
- Selenium の `fill_in` は実際にブラウザフォーカスを動かすため、その後の `execute_script` による合成イベント発火と干渉することがある。複数フィールドを連携してテストする場合は `execute_script` で一括設定するほうが安定する
- システムテストはフルスイートでのみ再現する不安定テストが存在する。孤立実行で通っても、フルスイート（多数のスペック前実行あり）で失敗するケースがあることを念頭に置く
