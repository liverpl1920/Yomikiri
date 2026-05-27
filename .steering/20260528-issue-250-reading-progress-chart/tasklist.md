# タスクリスト

## 🚨 タスク完全完了の原則

このファイルの全タスクが完了するまで作業を継続すること。

## フェーズ1: 設計反映とデータ整形

- [x] requirements.md / design.md を Issue #250 要件で具体化
- [x] BooksController に読書進捗グラフ用データ整形処理を追加
	- [x] 表示期間を「開始日〜今日（読了本は読了日）」で決定
	- [x] 日次ページ数を集計し、未記録日を 0 補完する

## フェーズ2: 画面実装

- [x] books/show に折れ線グラフセクションを追加
	- [x] 横軸（日付）と縦軸（ページ数）を表示
	- [x] データなし時の空状態を表示
	- [x] 既存詳細画面要素とのレイアウト整合を維持
- [x] books.css にグラフ用スタイルを追加

## フェーズ3: テストと検証

- [x] Request spec にグラフ表示とデータ反映のテストを追加
- [x] `bundle exec rspec spec/requests/books_spec.rb` を実行して通過
- [x] `bundle exec rubocop` を実行して通過
- [x] ~~`npm test`~~（実装方針上不要: Railsアプリで package.json に test script が存在せず `Missing script: "test"`）
- [x] ~~`npm run lint`~~（実装方針上不要: Railsアプリで package.json に lint script が存在せず `Missing script: "lint"`）
- [x] ~~`npm run typecheck`~~（実装方針上不要: Railsアプリで package.json に typecheck script が存在せず `Missing script: "typecheck"`）

## フェーズ4: 振り返り

- [x] 実装後の振り返りを本ファイルに記録

---

## 実装後の振り返り

### 実装完了日
2026-05-28

### 計画と実績の差分

計画と異なった点:
- 「全期間」の開始日を initially 作成日基準で実装したが、Issue文脈に合わせて初回読書ログ日基準へ修正した

新たに必要になったタスク:
- 実装検証サブエージェント指摘を受け、開始日仕様の修正テストを追加した

技術的理由でスキップしたタスク:
- `npm test` / `npm run lint` / `npm run typecheck`
	- スキップ理由: Railsリポジトリに該当 npm script が存在しないため
	- 代替実装: `bundle exec rspec spec/requests/books_spec.rb` と `bundle exec rubocop` を実行して品質確認

### 学んだこと

技術的な学び:
- SVG 折れ線グラフは外部ライブラリなしでも要件を満たせる
- 日次補完は `(start_date..end_date)` と `group(:read_at).sum(:pages_read)` の組み合わせが簡潔

プロセス上の改善点:
- 実装検証サブエージェントを中間で回すと仕様ズレを早期に是正できる

### 次回への改善提案

- 「読書開始日」の定義（登録日/初回ログ日）をIssue起票時に明文化する
- グラフ系列の合算（同日複数ログ）や1点データケースのテストを初期計画に含める
