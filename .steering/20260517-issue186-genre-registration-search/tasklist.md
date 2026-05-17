# タスクリスト: 積読登録時のジャンル登録と一覧検索へのジャンル追加 (Issue #186)

## フェーズ1: データモデルと保存処理

- [x] `books` テーブルに `genre` カラムを追加
	- [x] マイグレーションを作成する
	- [x] `db/schema.rb` を更新する

- [x] `Book` モデルにジャンルバリデーションと検索スコープを追加
	- [x] `genre` の長さバリデーションを追加
	- [x] `genre_like` スコープを追加
	- [x] `filtered_for_index` にジャンル条件を統合

- [x] `BooksController` の保存処理に `genre` を追加
	- [x] `book_params` に `genre` を追加
	- [x] 登録時に `genre` が保存されることを確認

## フェーズ2: 自動入力と検索UI拡張

- [x] `BooksController#search` でジャンル取得を返却
	- [x] ISBN検索（openBD）でジャンル抽出処理を追加
	- [x] タイトル検索（Google Books）でジャンル抽出処理を追加
	- [x] JSONレスポンスに `genre` を含める

- [x] 書籍登録フォームにジャンル入力欄を追加
	- [x] `app/views/books/_form.html.erb` に `genre` フィールドを追加
	- [x] バリデーションエラー表示を追加

- [x] Stimulus自動入力をジャンル対応に更新
	- [x] `book_form_controller.js` のフォーム反映対象に `genre` を追加
	- [x] 自動取得メッセージの不足項目表示に `ジャンル` を反映

- [x] 一覧検索フォームと検索条件にジャンルを追加
	- [x] `app/views/books/index.html.erb` にジャンル入力を追加
	- [x] `BooksController#index` の検索パラメータ正規化に `genre` を追加

## フェーズ3: テスト更新

- [x] model spec を更新
	- [x] `genre` バリデーションの正常系・異常系を追加
	- [x] `genre_like` / 複合検索の期待値を追加

- [x] request spec を更新
	- [x] `POST /books` のジャンル保存テストを追加
	- [x] `GET /books` のジャンル単体検索テストを追加
	- [x] `GET /books` のジャンル複合検索テストを追加

- [x] system spec を必要最小限で更新
	- [x] ~~自動取得成功時にジャンルが反映されるケースを追加~~（理由: 既存のtitle自動補完system specが非決定的で、受け入れ条件はrequest specでAPIレスポンスのジャンル返却と登録保存を担保済みのため、安定性優先でrequest層検証に統合）
	- [x] ジャンル未取得時の手入力保存ケースを追加（必要ならrequestで代替）

## フェーズ4: 検証

- [x] implementation-validator で品質確認
- [x] ~~`npm test` を実行~~（理由: 本リポジトリはNodeプロジェクトではなく、`package.json`に`test`スクリプトが存在しないため実行対象外）
- [x] ~~`npm run lint` を実行~~（理由: 本リポジトリはNodeプロジェクトではなく、`package.json`に`lint`スクリプトが存在しないため実行対象外）
- [x] ~~`npm run typecheck` を実行~~（理由: 本リポジトリはNodeプロジェクトではなく、`package.json`に`typecheck`スクリプトが存在しないため実行対象外）
- [x] `bundle exec rspec` を実行
- [x] `bundle exec rubocop` を実行

## フェーズ5: 仕上げ

- [x] tasklist.md に振り返りを記載
- [x] Issue番号付きでコミット
- [x] ブランチをpushしてPRを作成
- [x] `gh pr checks --watch` でCI完了を確認

## 申し送り事項

### 実装完了日
2026-05-17

### 計画と実績の差分
- 外部API周りで、テスト環境に設定された`RAKUTEN_APPLICATION_ID`により全体RSpecで不要な外部呼び出しが発生したため、test環境ではfixture用キー（`test_app_id`）のみ有効化する制御を追加した
- system specでジャンル自動反映のUI検証を追加すると既存不安定要因と干渉したため、request specでAPIレスポンスと保存動作の担保を強化して代替した

### 学んだこと
- 検索API拡張時は「返却項目追加」だけでなく既存のfallback順序（openBD -> Rakuten -> Google）の副作用まで含めて回帰確認が必要
- テスト環境に実運用向けENVが混在していると、WebMock前提テストで想定外経路に入りやすいため、環境依存のガードが有効

### 次回への改善提案
- `books/search`のレスポンス契約（title/author/genre/page/cover）をrequest specで共通化し、項目追加時の回帰を検知しやすくする
- system specの外部API依存ケースは、UI期待値を最小化し不安定になりやすい文言依存を減らす
