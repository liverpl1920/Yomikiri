# タスクリスト

## 🚨 タスク完全完了の原則

**このファイルの全タスクが完了するまで作業を継続すること**

## フェーズ1: データベースとモデルの実装

- [x] 1-1. `yearly_goal` カラムを `users` テーブルに追加するマイグレーションを作成・実行
  - [x] マイグレーションファイルの作成 (`bundle exec rails g migration AddYearlyGoalToUsers yearly_goal:integer`)
  - [x] デフォルト値を `50`、`null: false` に修正
  - [x] マイグレーションの実行 (`bundle exec rails db:migrate` および `RAILS_ENV=test bundle exec rails db:migrate`)
- [x] 1-2. `User` モデルにバリデーションを追加 (`app/models/user.rb`)
  - [x] `yearly_goal` の `presence`、`only_integer`、`greater_than_or_equal_to: 1` バリデーションを追加
- [x] 1-3. モデルスペックでバリデーションをテスト (`spec/models/user_spec.rb`)
  - [x] `yearly_goal` のバリデーションテストケースを追加・実行

## フェーズ2: コントローラーとビューの改修

- [x] 2-1. `MypagesController` の改修
  - [x] ストロングパラメータ `nickname_params` を `user_params` にリネームし、`yearly_goal` を許可
  - [x] 更新完了のフラッシュメッセージを「プロフィールを更新しました。」に変更
- [x] 2-2. 翻訳ファイルの更新 (`config/locales/ja.yml`, `config/locales/en.yml`)
  - [x] `user` の属性 `yearly_goal` の翻訳を追加
- [x] 2-3. マイページビューの改修 (`app/views/mypages/show.html.erb`)
  - [x] プロフィール一覧に「年間目標」を表示
  - [x] プロフィール編集フォームに `yearly_goal` の入力欄を追加
  - [x] エラーメッセージの表示をニックネーム個別から `current_user.errors.full_messages` のループに変更
- [x] 2-4. ダッシュボードビューの改修 (`app/views/dashboards/show.html.erb`)
  - [x] `yearly_target = 50` から `yearly_target = current_user.yearly_goal` へ変更

## フェーズ3: テストと検証

- [x] 3-1. リクエストスペックおよびシステムスペックの作成・更新
  - [x] `spec/requests/mypages_spec.rb` （または相当のテスト）の作成・更新
  - [x] `spec/system/mypages_spec.rb` （または相当のテスト）の作成・更新
- [x] 3-2. RSpecによるテスト全体の実行
  - [x] `bundle exec rspec`
- [x] 3-3. RuboCopによるコードスタイルチェックと修正
  - [x] `bundle exec rubocop`

## フェーズ4: コミットとPR作成

- [x] 4-1. 変更内容のコミットとリモートへのプッシュ
  - [x] `git commit -m "feat: マイページから年間目標を設定できるようにする (#334)"`
- [x] 4-2. プルリクエストの作成
  - [x] `gh pr create` を実行

---

## 実装後の振り返り

### 実装完了日
2026-06-07

### 計画と実績の差分

**計画と異なった点**:
- コミット前のテスト実行中にデータベースのマイグレーションが並行して実行されたことにより、すでに読み込まれていた `PreparedStatement` が一時的に無効（`PreparedStatementCacheExpired`）になり、一部テストが一時的に失敗した。その後、改めてクリーンな状態で `bundle exec rspec` を実行することで、すべて成功することを確認した。

**新たに必要になったタスク**:
- 特になし。

**技術的理由でスキップしたタスク**（該当する場合のみ）:
- 特になし。

### 学んだこと

**技術的な学び**:
- テスト実行中のスキーマ変更による `PreparedStatementCacheExpired` エラーについて。テスト中にDB定義を変えることの影響を再認識した。
- Rails の `errors.full_messages` を一括でビューに展開するエラーハンドリング構成。これにより、ニックネームだけでない複数カラムのバリデーションを単一エラーエリアでカバーできた。

**プロセス上の改善点**:
- ステアリングファイル（タスクリスト、設計書、要件書）に基づき、計画通りにスムーズに実装が進んだ。

### 次回への改善提案
- テスト実行中の `db:migrate` などのスキーマ変更を避けるため、テストが起動する前にマイグレーションを確実に完了させる運用に気をつける。
