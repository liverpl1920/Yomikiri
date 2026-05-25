# 要求内容

## 概要

書籍登録画面で書影auto-fetch後にファイルアップロードすると `cover_image_url` バリデーションエラーが発生するバグを修正する。

## 背景

タイトルまたはISBN入力後のauto-fetchが成功すると、`_fillFormFromSearch` が `book_cover_image_url`（hidden フィールド）に取得したURLをセットする。その後ユーザーがファイルを選択しても hidden フィールドをクリアするコードが存在しないため、フォーム送信時に `cover_image_url`（auto-fetch URL）と `cover_image`（ユーザーのファイル）の両方がサーバーへ送信され、意図しない `cover_image_url_must_be_valid_url` バリデーションが実行される。

## 実装対象の機能

### 1. ファイル選択時に cover_image_url hidden フィールドをクリア

- `book_cover_image` ファイル入力（`#book_cover_image`）の `change` イベントをStimulus コントローラーで購読
- ファイルが選択されたとき、`book_cover_image_url` hidden フィールドの値を空文字列にクリアする

## 受け入れ条件

### ファイル選択時の hidden フィールドクリア

- [ ] 書影auto-fetch後にファイルを選択して登録しても、`cover_image_url` バリデーションエラーが発生しない
- [ ] ファイルを選択後にauto-fetchが走っても、選択済みファイルはクリアされない（逆方向の干渉なし）
- [ ] 書影URLのみで登録（ファイル未選択）は従来どおり動作する
- [ ] RSpec が全通過する
- [ ] RuboCop がエラーなし

## スコープ外

以下はこのフェーズでは実装しません:

- ファイル選択後に書影プレビューを更新する機能（別Issue）
- cover_image_url hidden フィールドの UI 表示（既存のまま）

## 参照ドキュメント

- `docs/architecture.md` - アーキテクチャ設計書
- `app/javascript/controllers/book_form_controller.js` - 対象ファイル
- `app/views/books/_form.html.erb` - ビューテンプレート
