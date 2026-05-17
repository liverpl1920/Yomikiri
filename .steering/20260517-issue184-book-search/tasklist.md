# タスクリスト: 積読一覧画面の検索機能追加 (Issue #184)

## フェーズ1: 検索クエリ実装

- [x] `app/models/book.rb` に一覧検索用スコープを追加
	- [x] タイトル部分一致（`title ILIKE`）
	- [x] 著者部分一致（`author ILIKE`）
	- [x] 読了期間開始日（`completed_at >= from.beginning_of_day`）
	- [x] 読了期間終了日（`completed_at <= to.end_of_day`）
	- [x] 複合条件をまとめて適用するクラスメソッドを追加

## フェーズ2: コントローラ実装

- [x] `app/controllers/books_controller.rb` の `index` に検索条件の受け取りを追加
	- [x] 検索用パラメータを `permit` で制限
	- [x] 期間パラメータのパースと正規化（逆転入力をswap）
	- [x] `@search_params` をビューへ渡し検索条件を保持

## フェーズ3: ビュー実装

- [x] `app/views/books/index.html.erb` に検索フォームを追加
	- [x] 書籍名入力
	- [x] 著者名入力
	- [x] 読了期間（開始日・終了日）入力
	- [x] 検索ボタン
	- [x] クリアリンク

## フェーズ4: リクエストスペック実装

- [x] `spec/requests/books_index_spec.rb` を新規作成
	- [x] 未ログイン時のリダイレクト確認
	- [x] タイトル検索
	- [x] 著者検索
	- [x] 期間検索（開始のみ/終了のみ/両側）
	- [x] 複合条件検索
	- [x] 逆転入力の正規化
	- [x] 既存ソート回帰確認

## フェーズ5: 検証

- [x] `bundle exec rspec spec/requests/books_index_spec.rb` を実行
- [x] ~~`bundle exec rspec` を実行~~（理由: 既存の `spec/system/books/isbn_autofetch_spec.rb:111` が本Issue無関係の不安定要因で継続失敗。対象spec単体は成功を確認）
- [x] `bundle exec rubocop` を実行

## フェーズ6: 振り返り

- [x] tasklist.md に実装完了日・差分・学び・改善提案を記載

## 申し送り事項

### 実装完了日
2026-05-17

### 計画と実績の差分
- 計画時点では検索フォーム追加のみだったが、実装で「検索0件専用の空状態メッセージ」を追加してUXを改善
- 回帰テストを強化し、検索時にも既存ソート（未了優先・期限順）が維持されることを明示的に検証

### 学んだこと
- `for_index_list` を再利用したまま条件を積み上げる設計により、既存ソート仕様を壊さずに検索拡張しやすい
- request spec はHTML全文の文字列一致より、DOM要素抽出ベースで判定したほうが誤検知を防げる

### 次回への改善提案
- 全体RSpecで不安定な `spec/system/books/isbn_autofetch_spec.rb:111` の安定化（待機条件とメッセージ更新タイミングの見直し）
- データ件数増加を見据え、`title/author` の部分一致検索は将来的に `pg_trgm` インデックス導入を検討する
