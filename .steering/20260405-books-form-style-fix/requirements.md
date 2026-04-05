# 要求定義: 積読登録フォームのスタイル修正

## Issue
#91: 積読登録フォームのスタイルが未定義のため、ブラウザデフォルト表示になっている

## 背景
- `/books/new` の入力フォームが、ログイン・新規登録画面と比べてデザインが崩れている
- テンプレートが参照している CSS クラスが `books.css` に定義されていない
- ブラウザのデフォルトスタイルで表示されてしまっている

## 目的
積読登録フォームのフィールド・ラベル・ボタン・エラー表示などが、ログイン画面や新規登録画面と統一されたデザインで表示されるようにする。

## 要求内容

### 対象ファイル
- `app/assets/stylesheets/books.css`（CSS追加）
- `app/views/books/_form.html.erb`（クラス名変更不要）
- `app/views/books/new.html.erb`（クラス名変更不要）

### 追加が必要な CSS クラス

| クラス名 | 使用箇所 |
|---------|--------|
| `.form-field` / `.form-field__*` | `app/views/books/_form.html.erb` |
| `.form-errors` / `.form-errors__*` | `app/views/books/_form.html.erb` |
| `.form-actions` | `app/views/books/_form.html.erb` |
| `.page-header` / `.page-header__*` | `app/views/books/new.html.erb` |
| `.book-form-wrapper` | `app/views/books/new.html.erb` |
| `.quota-preview` / `.quota-preview__*` | `app/views/books/_form.html.erb` |

## デザイン基準
- `auth.css` の `.form-group` / `.form-label` / `.form-input` を参考にする
- CSS カスタムプロパティ（デザイントークン）を活用して統一感を持たせる
- BEM命名規則に従う

## 完了条件
- 全クラスが `books.css` に定義されている
- 積読登録フォームがログイン画面と統一されたデザインで表示される
- 既存の `books.css` スタイルを壊さない
