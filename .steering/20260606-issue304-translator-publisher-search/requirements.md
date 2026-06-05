# Issue #304 要件定義

## 概要

積読一覧画面の検索条件に「翻訳者」での検索機能を追加し、「出版社」検索の動作を担保する。

## 背景

- `books_controller.rb` の `SUGGESTION_FIELDS` に `"publisher"` が含まれていない → サジェストAPIが 400 を返す。
- ビューの出版社フィールドには `data-search-filter-autocomplete-field-value="publisher"` がセットされているが、バックエンドの SUGGESTION_FIELDS に `publisher` が含まれていない。
- 翻訳者（translator）の検索スコープ・検索フォームが未実装。

## 実装内容

### 1. モデル層
- `scope :translator_like` を追加（既存の `publisher_like` と同パターン）
- `filtered_for_index` に翻訳者絞り込みを追記

### 2. コントローラー層
- `SUGGESTION_FIELDS` に `"translator"` を追加（`"publisher"` は既存だが追加確認）
- `normalized_index_search_params` に `:translator` を追加

### 3. ビュー層
- 検索フォームに「翻訳者」フィールドを追加（著者・出版社と同様のオートコンプリート実装）

### 4. テスト
- `spec/models/book_spec.rb`: `.filtered_for_index` への翻訳者・出版社の絞り込みテスト追加
- `spec/system/books/search_filter_autocomplete_spec.rb`: 翻訳者・出版社フィールドのテスト追加

## 検証
- 翻訳者・出版社フィールドで絞り込みが正しく動作すること
- オートコンプリート候補が表示されること
- `bundle exec rspec` がパスすること
