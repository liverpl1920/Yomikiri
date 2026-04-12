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
- [ ] コミット・プッシュ・PR 作成
- [ ] CI 通過確認

---

## 実装後の振り返り

（全タスク完了後に記載）
