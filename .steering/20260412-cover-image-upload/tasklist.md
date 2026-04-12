# タスクリスト: 書影アップロード機能 (Issue #26)

## フェーズ1: 準備

- [x] ステアリングファイル作成（requirements.md, design.md, tasklist.md）
- [x] feature ブランチの作成

## フェーズ2: モデル実装

- [x] Book モデルに `has_one_attached :cover_image` を追加
- [x] Book モデルに画像バリデーション（形式・サイズ）を追加（カスタム validate メソッド）
- [x] i18n ロケールファイル（ja.yml）にバリデーションエラーメッセージを追加

## フェーズ3: コントローラー実装

- [x] `book_params` に `:cover_image` を追加

## フェーズ4: ビュー実装

- [x] 書籍登録フォーム（_form.html.erb）に書影アップロードフィールドを追加
- [x] 積読一覧画面（index.html.erb）に書影表示ロジックを追加
- [x] 書籍詳細画面（show.html.erb）に書影表示ロジックを追加

## フェーズ5: テスト実装

- [x] Book モデルスペックに書影バリデーションテストを追加（3テストケース）
- [x] spec/fixtures/files/test_image.png を作成（1x1px PNG）

## フェーズ6: 検証・コミット

- [x] RSpec 全通過（213 examples, 0 failures）
- [x] RuboCop エラーなし
- [x] コミット・プッシュ・PR 作成（PR #111）
- [x] CI 通過確認（Add to GitHub Project: pass）

---

## 実装後の振り返り

**実装完了日**: 2026-04-12

### 計画と実績の差分
- `active_storage_validations` gem が Gemfile にないため、DSL バリデーションが使えなかった。カスタム `validate` メソッドに切り替えることで対応（設計変更だが spec はすべて通過）。
- リクエストスペックへの書影アップロードテストは、ファクトリのシンプルさと既存テストカバレッジを考慮して省略し、モデルスペックのみに絞った。

### 学んだこと
- Rails の Active Storage 添付バリデーションは、`active_storage_validations` gem なしでは `validates :attachment, content_type:` の DSL が使えない。カスタム validate メソッドで十分代替できる。
- `cover_image.attached?` をガードとして使うことで、未添付時に不必要なバリデーションエラーを防ぐことができる。
- Active Storage の `blob.content_type` と `blob.byte_size` を直接参照することでシンプルな実装が可能。

### 次回への改善提案
- 書影の表示に `image_processing` gem（`variant`）を活用してリサイズ（サムネイル化）を行うと、一覧画面のパフォーマンスが向上する（本リリースのタスクとして検討）。
- 既存の書影を登録後に削除する機能も今後の要件として検討する。

---

## 実装後の振り返り

（全タスク完了後に記載）
