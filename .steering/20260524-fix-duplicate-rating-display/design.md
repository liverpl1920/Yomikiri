# 設計書

## アーキテクチャ概要

Rails MVCのビュー層のみの修正。Viewファイル（ERBテンプレート）から重複要素を削除する。

## コンポーネント設計

### 1. app/views/books/show.html.erb（評価・感想セクション）

**責務**:
- 読了本の評価・感想を入力・表示するフォームを提供する

**現状の問題**:
- 評価フォーム内に2つの評価表示が存在する
  1. `book-show__stars`（ラジオボタン形式の評価入力、星アイコン付き）
  2. `book-show__stars-display`（`@book.rating.present?` 条件付きの静的評価表示）

**修正方針**:
- `book-show__stars-display` 全体（`<% if @book.rating.present? %>` ブロック）を削除する
- ラジオボタン形式（`book-show__stars`）は保持し、入力と現在選択状態の両方を担う
  - `checked: @book.rating == star` による既存のチェック状態は維持されている

## データフロー

### 評価表示
```
1. コントローラーが @book を取得
2. show.html.erb が @book.rating を参照
3. ラジオボタンの checked 状態で現在の評価を表示（変更なし）
4. book-show__stars-display ブロックを削除 → 重複解消
```

## エラーハンドリング戦略

特になし（View層の削除のみ）。

## テスト戦略

- 既存のRSpecテストが通ることを確認
- system specで評価表示が重複しないことを確認
