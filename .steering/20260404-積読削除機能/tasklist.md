# タスクリスト: 積読削除機能 (Issue #17)

## 🚨 タスク完全完了の原則

**このファイルの全タスクが完了するまで作業を継続すること**

---

## フェーズ1: バックエンド実装

- [x] `config/routes.rb` に `destroy` を追加
- [x] `BooksController` に `destroy` アクションを追加
  - [x] `before_action :set_book` の対象に `:destroy` を追加
  - [x] `destroy` アクションの実装（削除後 `books_path` へリダイレクト）

## フェーズ2: フロントエンド実装

- [x] Stimulus `modal_controller.js` を作成
- [x] `app/javascript/controllers/index.js` にモーダルコントローラを登録
- [x] `app/views/books/show.html.erb` に「削除する」ボタンを追加
- [x] `app/views/books/show.html.erb` に削除確認モーダルを追加
- [x] モーダルの CSS スタイルを追加

## フェーズ3: テスト実装

- [x] `spec/requests/books_spec.rb` に `DELETE /books/:id` のテストを追加
  - [x] 未ログイン時は 302 リダイレクト（ログイン画面）
  - [x] ログイン済み・自分の書籍：削除成功し `books_path` へリダイレクト
  - [x] ログイン済み・他ユーザーの書籍：404 を返す（削除されない）

## フェーズ4: 品質チェック

- [x] `bundle exec rspec` が全件通過
- [x] `bundle exec rubocop` にエラーがない

---

## 実装後の振り返り

**実装完了日**: 2026-04-04

**計画と実績の差分**:
- 計画通りに全タスクを完了。
- `index.js` の修正は不要だった（`eagerLoadControllersFrom` が自動でファイルをロードするため）。
- `btn--danger` CSS クラスが既存になかったため `application.css` に追加した（design.md では未記載）。

**学んだこと**:
- Stimulus の `eagerLoadControllersFrom` があれば `index.js` に手動登録不要。
- `hidden` 属性の toggle で CSS フレームワーク不要のシンプルなモーダルが実現できる。
- RuboCop は JS ファイルを対象に含めると構文エラー扱いになるため、Ruby ファイルのみを指定する必要がある。

**次回への改善提案**:
- `btn--danger` など汎用ユーティリティクラスは設計段階でリストアップしておく。
- モーダルのアクセシビリティ（フォーカストラップ、Escape キー対応）は今後の拡張要件として検討する。
