# 設計書

## 実装アプローチ

### 変更対象ファイル

| ファイル | 変更内容 |
|---------|---------|
| `app/javascript/controllers/book_form_controller.js` | `_performFetchByTitle` で取得結果を判定し、詳細フィードバックメッセージ生成。書影プレビュー表示メソッド追加 |
| `app/views/books/_form.html.erb` | 書影プレビュー用の `<img>` 要素と Stimulus target を追加 |
| `app/assets/stylesheets/books.css` | 書影プレビューのスタイル追加 |
| `spec/system/books/book_form_feedback_spec.rb` | 新規：フィードバック表示のシステムスペック |

### フィードバックロジック（JavaScript）

```
取得成功判定:
  - 全フィールド（author, total_pages, cover_image_url）が取得できた → 「成功」
  - 一部フィールドが空 → 「部分取得」（どのフィールドが不足か列挙）
  - books が空またはエラー → 「失敗」

メッセージ例:
  成功: "タイトル・著者・ページ数・書影をすべて取得しました。"
  部分取得: "書籍情報を取得しましたが、書影は取得できませんでした。"
  部分取得（複数）: "書籍情報を取得しましたが、著者・書影は取得できませんでした。"
  失敗: "書籍情報を取得できませんでした。ISBNで検索してみてください。"
```

### 書影プレビュー（HTML + JavaScript）

- フォームの titleStatus の下に `<div data-book-form-target="coverPreview">` を追加
- 書影URLが取得できた場合: `<img>` を表示
- 書影URLが空の場合: プレビューを非表示のままにする

### Stimulus targets 追加

```js
static targets = [...既存..., 'coverPreview']
```
