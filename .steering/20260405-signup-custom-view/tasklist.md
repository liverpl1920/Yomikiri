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

- [x] コミット (`#85 Sign Up画面カスタムデザイン適用`)
- [x] push & PR 作成
- [x] CI 確認

---

## 振り返り

### 実装完了日
2026-04-05

### 計画と実績の差分

| 項目 | 計画 | 実績 |
|------|------|------|
| 新規作成ファイル | `new.html.erb` 1ファイル | `new.html.erb` 1ファイル + コントローラ修正 |
| 既存テスト修正 | 計画になし | `sign_up_spec.rb` を3箇所更新（ボタン名・CSSセレクタ変更）|

**計画外作業**: 既存のシステムスペック（`spec/system/auth/sign_up_spec.rb`）が Devise デフォルトビューを前提にした英語ボタン名・CSS IDで書かれていたため、カスタムビューに合わせて更新が必要だった。

### 学んだこと

1. Devise のカスタムビュー追加時は、既存のシステムスペックも確認・更新が必要。デフォルトビューを前提にしたスペックは壊れる。
2. `devise_parameter_sanitizer.permit` で `nickname` を許可する際、RuboCop の `Layout/SpaceInsideArrayLiteralBrackets` に注意（`[:nickname]` → `[ :nickname ]`）。
3. 登録バリデーションエラーは `resource.errors` で view に渡されるため、`#error_explanation` ではなく独自のエラー表示要素（`.auth-card__errors`）を実装した。

### 次回への改善提案

- カスタムデザインビューを新規作成する際は、関連するシステムスペックを事前に確認し、tasklist に「スペック更新」タスクを含める。
- Devise の strong parameters 追加は `configure_sign_up_params` パターンで統一する（このプロジェクトの慣例として記録）。

