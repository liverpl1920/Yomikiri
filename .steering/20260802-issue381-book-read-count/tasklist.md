# タスクリスト

## 🚨 タスク完全完了の原則

**このファイルの全タスクが完了するまで作業を継続すること**

### 必須ルール
- **全てのタスクを`[x]`にすること**
- 「時間の都合により別タスクとして実施予定」は禁止
- 「実装が複雑すぎるため後回し」は禁止
- 未完了タスク（`[ ]`）を残したまま作業を終了しない

---

## フェーズ1: データベースの変更と移行

- [x] マイグレーションファイルの作成
  - [x] `rails g migration AddReadCountToBooks` コマンドの実行
  - [x] `read_count` カラム (integer, default: 0, null: false) の定義を追加
  - [x] 既存の completed 書籍データの移行処理（同一タイトル重複本は古い順に 1, 2, 3...、その他の completed 本は 1 を設定）をマイグレーション内に記述
- [x] マイグレーションの実行
  - [x] `bundle exec rails db:migrate` の実行
  - [x] `db/schema.rb` に正しく反映されていることの確認

## フェーズ2: モデルとコントローラの実装

- [x] `Book` モデルの修正
  - [x] `Book.normalize_title` の修正（`【N度目】` プレフィックスの除去処理追加）
  - [x] `before_save` コールバック `set_initial_read_count_on_completion` の追加
  - [x] `display_title` の修正（動的なサフィックス付与の廃止）
- [x] `BooksController` の修正
  - [x] `new` アクションの `copy_from_id` 指定時の挙動修正（`read_count` カウントアップとタイトルプレフィックス付与）
  - [x] `book_params` の Strong Parameters に `:read_count` を追加

## フェーズ3: テストの追加と修正

- [x] モデルスペックの修正と追加 (`spec/models/book_spec.rb`)
  - [x] `.normalize_title` が `【N度目】` を除去して正規化するテストの追加
  - [x] `before_save` 時の `read_count` 自動設定（`completed` 時に `0` から `1` になること）のテスト追加
  - [x] 既存の `display_title` のテストを新しい仕様（プレフィックス付きのタイトルをそのまま返す）に合わせて修正
- [x] リクエストスペックの修正と追加 (`spec/requests/books_spec.rb`)
  - [x] `copy_from_id` 指定時の `read_count` の引き継ぎ・カウントアップとタイトル自動付与に関するテストの追加
- [x] システムスペックの修正 (`spec/system/books/books_crud_spec.rb`)
  - [x] 「もう一度読む」リンククリック時の挙動（遷移先タイトルおよび登録後の表示）に関するテストの修正

## フェーズ4: 品質チェックと検証

- [x] テストの実行とパス確認
  - [x] `bundle exec rspec` の実行
- [x] コードスタイルの確認
  - [x] `bundle exec rubocop` の実行

## フェーズ5: ドキュメント更新と振り返り

- [x] 振り返りの記録（このファイルの下部）

---

## 実装後の振り返り

### 実装完了日
2026-08-02

### 計画と実績の差分

**計画と異なった点**:
- データベース移行時、PostgreSQL の `SELECT DISTINCT` において `find_each` の主キーソート (`ORDER BY id`) が競合しエラーとなったため、`unscope(:order).distinct.each` を使用するようにロジックを修正しました。

**新たに必要になったタスク**:
- 既存の重複警告テスト `spec/system/books/duplicate_title_warning_spec.rb` が、`display_title` メソッドの動的サフィックス廃止に伴い失敗することが確認されたため、新仕様（プレフィックス付きのまま表示）に合うようテストケースを修正しました。

**技術的理由でスキップしたタスク**:
- なし

### 学んだこと

**技術的な学び**:
- PostgreSQL の `DISTINCT` 制約下における Active Record の `find_each` バッチ処理の注意点について改めて理解を深めました。
- 既存機能をリプレイスする際は、関連する一見無関係に見えるテスト（今回は重複登録関連）への波及を早期にキャッチアップすることが重要であると実感しました。

**プロセス上の改善点**:
- テスト全体を早い段階で回しておくことで、破壊的な影響を検出してスムーズに対処できました。
