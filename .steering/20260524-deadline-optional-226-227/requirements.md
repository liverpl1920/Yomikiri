# 要件定義: ISSUE#226, #227 読了期限の任意化

## 作業概要

- **Issue #226**: 過去に読んだ本の登録時は読了期限を必須にしない
- **Issue #227**: 積読登録時は読了期限を必須にせず、読み始めた時点で必須にする

## 背景

現在 `validates :deadline, presence: true` により全書籍で読了期限が必須。
- 積読（unread）登録時にまだ期限が決まっていないケースに対応できない
- 過去読書登録時に当時の期限を正確に入力できないケースに対応できない

## 要件詳細

### ISSUE#226: 過去読書登録時の期限任意化

- `is_past_reading` フラグが true の場合、読了期限を任意入力とする
- 読了期限が未入力でも保存できる
- 完了条件: 過去読書登録時に読了期限未入力で保存できる

### ISSUE#227: 積読登録時の期限任意化

- 積読（unread ステータス）で登録する場合、読了期限を任意入力とする
- 読み始めた（unread → reading への遷移）タイミングでは読了期限が必須
- `auto_set_reading_status` が発動するタイミング（current_page が 0 → >0）で必須チェック
- 完了条件:
  1. 積読登録時に読了期限未入力で保存できる
  2. 読書開始時（進捗更新で unread → reading 遷移）は読了期限が必須
  3. 既存の登録・編集・状態変更機能に回帰不具合がない

## 現行仕様の「読み始めたタイミング」定義

`auto_set_reading_status` コールバックの発動条件：
- `unread?` であること
- `persisted?` であること（既存レコード）
- `current_page` が変化すること
- `current_page_was` が 0 であること（初めての進捗記録）
- 新しい `current_page` が 0 より大きいこと

## 影響範囲

- `app/models/book.rb` - バリデーションロジック
- `app/views/books/_form.html.erb` - フォームのUI（必須/任意ラベル）
- `app/views/books/show.html.erb` - 詳細画面（nil deadline 対応）
- `app/views/books/index.html.erb` - 一覧画面（nil deadline 対応）
- `spec/models/book_spec.rb` - モデルスペック更新・追加
