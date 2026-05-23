# tasklist.md

## タスクリスト

### フェーズ1: 準備
- [x] ステアリングファイルの作成 (requirements.md, design.md, tasklist.md)
- [ ] feature ブランチの作成 (`feature/#206-memo-datetime-and-clear`)

### フェーズ2: データ層
- [ ] migration: `books` テーブルに `memo_updated_at` (datetime, nullable) を追加
- [ ] `db:migrate` を実行してスキーマを更新

### フェーズ3: コントローラー
- [ ] `BooksController#update_memo` で `memo_updated_at: Time.current` を設定
- [ ] `flash[:memo_saved] = true` をリダイレクト前にセット

### フェーズ4: ビュー
- [ ] `books/show.html.erb`: テキストエリアを `flash[:memo_saved]` 時は空にする
- [ ] `books/show.html.erb`: 保存済みメモに `memo_updated_at` の日時を表示

### フェーズ5: テスト
- [ ] `spec/requests/books_spec.rb`: `memo_updated_at` が更新されることをテスト
- [ ] `spec/requests/books_spec.rb`: 保存後リダイレクト先でテキストエリアが空であることをテスト
- [ ] `spec/requests/books_spec.rb`: 保存済みメモに日時が表示されることをテスト

### フェーズ6: 検証
- [ ] `bundle exec rspec spec/requests/books_spec.rb` でテスト全通過
- [ ] `bundle exec rspec` で全テスト通過
- [ ] `bundle exec rubocop` でエラーなし

### フェーズ7: コミット・PR
- [ ] コミット (#206 メモ欄に記録日時表示と保存後入力クリアを追加)
- [ ] push & PR 作成

---
## 振り返り
（完了後に記載）
