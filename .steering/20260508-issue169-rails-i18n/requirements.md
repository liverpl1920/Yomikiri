# 要求内容

## 概要

バリデーションエラーメッセージが英語で表示される問題を修正するため、`rails-i18n` gem を導入し、標準Railsバリデーションメッセージを日本語化する。

## 背景

MVPレビュー（#41）にて、新規登録画面・書籍登録画面でバリデーションエラーメッセージが英語で表示されている問題が指摘された。`Gemfile` に `rails-i18n` gem が含まれていないため、Railsの標準バリデーションメッセージが日本語に翻訳されない状態になっている。

`config/locales/ja.yml` にはモデル名・属性名・カスタムバリデーション（`deadline`, `target_pages` 等）の日本語訳は定義されているが、標準メッセージ（`blank`, `too_long` など）が未定義のため英語にフォールバックしてしまう。

## 影響範囲

以下のページの全フォームで、標準Railsバリデーションメッセージが英語表示になっている：

- ユーザー新規登録（`/users/sign_up`）
- ユーザーログイン（`/users/sign_in`）
- パスワード変更（`/users/password/edit`）
- アカウント設定編集（`/users/edit`）
- 書籍登録（`/books/new`）
- 書籍編集（`/books/:id/edit`）
- メールアドレス変更（`/users/email_changes/edit`）

## 実装対象の機能

### 1. `rails-i18n` gem の導入

- `Gemfile` に `gem "rails-i18n", "~> 7.0"` を追加
- `bundle install` を実行してGemをインストール
- この gem により、以下の標準バリデーションメッセージが自動的に日本語化される：

| 標準メッセージキー | 英語（現状） | 期待する日本語 |
|---|---|---|
| `blank` | can't be blank | を入力してください |
| `too_long` | is too long (maximum is %{count} characters) | は%{count}文字以内で入力してください |
| `too_short` | is too short (minimum is %{count} characters) | は%{count}文字以上で入力してください |
| `not_a_number` | is not a number | は数値で入力してください |
| `not_an_integer` | must be an integer | は整数で入力してください |
| `greater_than` | must be greater than %{count} | は%{count}より大きい値にしてください |
| `greater_than_or_equal_to` | must be greater than or equal to %{count} | は%{count}以上の値にしてください |

Deviseの`:validatable`モジュールが追加するパスワード長バリデーションなども日本語化される。

## 受け入れ条件

### `rails-i18n` gem 導入

- [ ] `Gemfile` に `rails-i18n` gem が追加されている
- [ ] `bundle install` が正常に完了する
- [ ] ユーザー新規登録で必須項目を空にした時に「を入力してください」と日本語で表示される
- [ ] 書籍登録で数値バリデーションエラーが日本語で表示される
- [ ] 既存のカスタムバリデーションメッセージが引き続き正しく動作する
- [ ] RSpec テストが全件通過する
- [ ] RuboCop エラーがない

## スコープ外

以下はこのフェーズでは実装しません:

- `ja.yml` への標準メッセージの手動追加（案Bは採用しない）
- 新しいバリデーションの追加
- テストケースの新規追加（既存テストの修正は対象）

## 参照ドキュメント

- `docs/architecture.md` - アーキテクチャ設計書
- `docs/development-guidelines.md` - 開発ガイドライン
- Issue #169 - バリデーションエラーメッセージの日本語未対応
