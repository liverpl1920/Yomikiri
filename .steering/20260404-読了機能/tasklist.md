# タスクリスト: 読了機能 (Issue #21)

## フェーズ1: 準備・バグ修正

- [x] show.html.erb の重複HTMLを修正（lines 213-276 の孤立コンテンツを削除）

## フェーズ2: ルーティング・コントローラ

- [x] routes.rb に `patch :complete` を追加
- [x] BooksController の before_action :set_book に `:complete` を追加
- [x] BooksController#complete アクションを実装

## フェーズ3: ビュー（書籍詳細）

- [x] show.html.erb に「読了にする！」ボタンを追加（未完了かつ progress_percentage == 100 の時強調）
- [x] show.html.erb に読了お祝いモーダル（W-13）を追加
  - タイトル・読了日・読了までの日数表示
  - 「一覧に戻る」ボタン（books_path）

## フェーズ4: ビュー（積読一覧）

- [x] index.html.erb の読了済み書籍カードに視覚的区別スタイルを追加

## フェーズ5: CSS

- [x] 「読了にする！」ボタン用CSS追加
- [x] 読了お祝いモーダル用CSS追加
- [x] 読了済みカードの視覚的区別CSS追加

## フェーズ6: テスト

- [x] PATCH /books/:id/complete のリクエストspecを追加
  - 認証済み: 正常完了（status=completed, completed_at設定、リダイレクト）
  - 認証済み: 他ユーザーの書籍は404
  - 未認証: ログインページへリダイレクト
  - モーダル表示: flash によりモーダルが表示される

## 申し送り事項

### 実装完了日
2026年4月4日

### 計画と実績の差分
- 計画通りに実装完了。追加対応として show.html.erb の重複HTML（lines 213-276 の孤立コンテンツ）を修正した。
- celebration modal は JavaScript なしでフラッシュ（`flash[:completed_book]`）を利用したシンプルな実装を採用。

### 学んだこと
- メインブランチのマージ後に孤立したHTMLが存在した。今後のPRでは必ず既存ビューを最後まで確認すること。
- Rails flash を活用することでJS不要のモーダル自動表示が実現できる。
- `button_to` は `form` タグを生成するため PATCH メソッドによる読了アクションに適切。

### 次回への改善提案
- 読了済み書籍に `completed_at` 表示（読了日）を詳細画面に追加するとUX向上になる。
- CSS の `pulse-green` アニメーションのアクセシビリティ考慮（`prefers-reduced-motion` メディアクエリ）。
