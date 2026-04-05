# タスクリスト: Sign Up画面カスタムデザイン適用

## フェーズ1: 準備

- [x] 既存のshared partialの確認（エラー表示など）
- [x] feature/#85-signup-custom-view ブランチ作成

## フェーズ2: 実装

- [x] `app/views/devise/registrations/` ディレクトリ作成と `new.html.erb` の実装
- [x] `app/controllers/users/registrations_controller.rb` に nickname の permit 追加

## フェーズ3: 検証

- [x] RSpec テスト実行（既存テスト pass 確認）
- [x] RuboCop 実行（エラーなし確認）

## フェーズ4: コミット & PR

- [ ] コミット (`#85 Sign Up画面カスタムデザイン適用`)
- [ ] push & PR 作成
- [ ] CI 確認

---

## 振り返り

（実装完了後に記載）
