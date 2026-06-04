# 設計書

## アーキテクチャ概要

既存の Rails MVC 構成を維持し、書籍詳細ビューと `BooksController#update_progress` の入力仕様を直接入力へ寄せる。DB スキーマやルーティングは変更しない。

## コンポーネント設計

### `app/views/books/show.html.erb`

**責務**:
- 書籍詳細画面の進捗更新フォームを表示する。

**実装の要点**:
- `pages_read` フォームと折りたたみ UI を削除する。
- `direct_page` 入力を通常表示し、現在ページと読了対象ページ数の範囲を HTML 属性で示す。

### `app/controllers/books_controller.rb`

**責務**:
- 進捗更新リクエストの値を検証し、現在ページを更新する。

**実装の要点**:
- `calculate_new_page` は `direct_page` のみを受け付ける。
- 読書ログ作成は既存の `create_reading_log_for_progress!` を継続利用する。

## テスト戦略

- Request spec で `direct_page` 更新、ログ記録、不正値、他ユーザー・未認証を確認する。
- System spec で詳細画面のフォーム表示と直接入力更新、エラー表示を確認する。

## 依存ライブラリ

追加なし。
