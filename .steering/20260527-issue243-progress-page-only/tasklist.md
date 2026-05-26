# タスクリスト

## 🚨 タスク完全完了の原則

**このファイルの全タスクが完了するまで作業を継続すること**

### 必須ルール
- **全てのタスクを`[x]`にすること**
- 「時間の都合により別タスクとして実施予定」は禁止
- 「実装が複雑すぎるため後回し」は禁止
- 未完了タスク（`[ ]`）を残したまま作業を終了しない

### 実装可能なタスクのみを計画
- 計画段階で「実装可能なタスク」のみをリストアップ
- 「将来やるかもしれないタスク」は含めない
- 「検討中のタスク」は含めない

### タスクスキップが許可される唯一のケース
以下の技術的理由に該当する場合のみスキップ可能:
- 実装方針の変更により、機能自体が不要になった
- アーキテクチャ変更により、別の実装方法に置き換わった
- 依存関係の変更により、タスクが実行不可能になった

スキップ時は必ず理由を明記:
```markdown
- [x] ~~タスク名~~（実装方針変更により不要: 具体的な技術的理由）
```

### タスクが大きすぎる場合
- タスクを小さなサブタスクに分割
- 分割したサブタスクをこのファイルに追加
- サブタスクを1つずつ完了させる

---

## フェーズ1: UI仕様変更

- [x] 書籍詳細画面の進捗更新UIをページ数指定のみに統一する
	- [x] 進捗更新フォームから +1 / -1 ボタンを削除する
	- [x] ラベル/補助文言がページ数指定のみの仕様と矛盾しないことを確認する

- [x] progress_update Stimulus の不要ロジックを整理する
	- [x] increment / decrement アクションと不要target/value定義を削除する
	- [x] toggleAdvanced の動作が維持されることを確認する

## フェーズ2: テスト更新

- [x] システムスペックを新UI仕様に合わせる
	- [x] +/− ボタン前提の検証を削除する
	- [x] +/− ボタンが表示されないことの検証を追加する
	- [x] 進捗更新と直接入力トグルの既存検証が通るよう調整する

- [x] リクエストスペックの回帰影響を確認する
	- [x] pages_read / direct_page の更新仕様に変更が不要なことを確認する

## フェーズ3: 品質チェックと修正

- [x] RSpec が通ることを確認
	- [x] `bundle exec rspec spec/system/books/progress_update_spec.rb`
	- [x] `bundle exec rspec spec/requests/books_spec.rb`

- [x] RuboCop が通ることを確認
	- [x] ~~`bundle exec rubocop app/javascript/controllers/progress_update_controller.js app/views/books/show.html.erb spec/system/books/progress_update_spec.rb`~~（理由: RuboCopはJavaScript/ERBをRuby構文として解釈しSyntaxエラーになるため）
	- [x] `bundle exec rubocop`（プロジェクト標準の実行方法）

- [x] add-featureプロンプト準拠コマンド実行
	- [x] ~~`npm test`~~（理由: package.jsonのscriptsにtestが存在しないため）
	- [x] ~~`npm run lint`~~（理由: package.jsonのscriptsにlintが存在しないため）
	- [x] ~~`npm run typecheck`~~（理由: package.jsonのscriptsにtypecheckが存在しないため）

## フェーズ4: ドキュメント更新

- [x] 実装変更が永続ドキュメント更新不要であることを確認する
- [x] 実装後の振り返り（このファイルの下部に記録）

---

## 実装後の振り返り

### 実装完了日
2026-05-27

### 計画と実績の差分

**計画と異なった点**:
- RuboCop対象にJavaScript/ERBを直接指定すると構文エラーになることが判明した。
- lint検証はプロジェクト標準の `bundle exec rubocop` に切り替えて確認した。

**新たに必要になったタスク**:
- 実装品質検証として implementation-validator サブエージェントを追加実行した。
- 変更範囲がUI中心だったため、サーバー挙動回帰を担保するために request spec 全体実行を明示した。

**技術的理由でスキップしたタスク**（該当する場合のみ）:
- `npm test` / `npm run lint` / `npm run typecheck`
	- スキップ理由: 本リポジトリに package.json scripts が存在しないため
	- 代替実装: `bundle exec rspec` と `bundle exec rubocop` を実行して品質確認

**⚠️ 注意**: 「時間の都合」「難しい」などの理由でスキップしたタスクはここに記載しないこと。全タスク完了が原則。

### 学んだこと

**技術的な学び**:
- UI入力方式を整理しても `BooksController#update_progress` の既存ロジックを維持すれば回帰を最小化できる。
- Stimulusコントローラーは責務を最小化するとテスト対象が明確になり、仕様変更に強くなる。

**プロセス上の改善点**:
- tasklistをフェーズ/サブタスクで分割したことで、実装と検証の進捗管理が容易だった。
- プロンプト指定コマンドが非適用の場合も、技術的理由を明記する運用が有効だった。

### 次回への改善提案
- 仕様変更時は最初に「UI/ロジック/テスト」の3層で影響範囲を固定してから作業すると手戻りが減る。
- RuboCop対象ファイルの種別（Ruby以外を含むか）を事前確認してlint手順を定義する。
- プロジェクトの検証コマンド体系（Ruby系/Node系）をtasklist作成時に明示しておく。
