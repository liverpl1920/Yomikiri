# 要求定義: Sign Up画面カスタムデザイン適用

## Issue

Issue #85: Sign Up画面がDeviseデフォルトのまま、カスタムデザインが未適用

## 問題点

- `/users/sign_up` がDeviseデフォルトビューのまま（英語・スタイルなし）
- ログイン画面（`/users/sign_in`）はカスタムデザイン適用済み
- Userモデルの `nickname` カラムが入力できない

## 期待する動作

- `.auth-page` / `.auth-card` レイアウト（ログイン画面と統一）
- 日本語ラベル・プレースホルダー
- メールアドレス入力フィールド
- ニックネーム入力フィールド（任意、最大50文字）
- パスワード入力フィールド
- パスワード確認入力フィールド
- 「登録する」送信ボタン
- フッターに「すでにアカウントをお持ちの方はログイン」リンク

## 影響範囲

- `app/views/devise/registrations/new.html.erb`（新規作成）
- `app/controllers/users/registrations_controller.rb`（`nickname` のpermit追加が必要）
