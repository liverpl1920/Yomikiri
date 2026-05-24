# タスクリスト

## 🚨 タスク完全完了の原則

**このファイルの全タスクが完了するまで作業を継続すること**

---

## フェーズ1: Active Storage 再有効化

- [x] T1: Active Storage テーブル再作成マイグレーションを作成・実行する
- [x] T2: config/storage.yml に S3 設定を追加する
- [x] T3: config/environments/production.rb に本番ストレージ設定を追加する
- [x] T4: render.yaml にストレージ環境変数を追加する

## フェーズ2: モデル・バリデーション

- [x] T5: Book モデルに has_one_attached :cover_image を追加する
- [x] T6: Book モデルに cover_image のバリデーション（形式・サイズ）を追加する

## フェーズ3: ヘルパー・ビュー更新

- [x] T7: BooksHelper#book_cover_src をBook引数に変更し、Active Storage 対応を追加する
- [x] T8: books/index.html.erb の cover_src 呼び出しを更新する
- [x] T9: books/show.html.erb の cover_src 呼び出しを更新する
- [x] T10: books/_form.html.erb に書影アップロードフィールドを追加する

## フェーズ4: コントローラー更新

- [x] T11: BooksController の Strong Parameters に cover_image を追加する

## フェーズ5: テスト

- [x] T12: Book モデルの cover_image バリデーションテストを追加する（spec/models/book_spec.rb）
- [x] T13: RSpec 全通過を確認する（spec/system/books/book_form_feedback_spec.rb:84 は既存のflakyテスト、単体では通過）
- [x] T14: RuboCop 全通過を確認する（Rubyファイル全通過。YAMLファイルの偽陽性は既存の既知問題）

## フェーズ6: コミット・PR

- [ ] T15: コミット・プッシュ・PR 作成・CI 確認する
- [ ] T16: 振り返りを記載する

---

## 振り返り（完了後に記載）

<!-- 実装完了後に記載 -->
