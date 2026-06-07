# 設計書

## アーキテクチャ概要

MVCパターン。コントローラーでログインユーザーに紐づく今年読了された本をフィルタリング・カウントし、ビューの「年間目標」欄で参照します。

## コンポーネント設計

### 1. DashboardsController (`app/controllers/dashboards_controller.rb`)

**責務**:
- ダッシュボード描画用データの準備
- 過去のデータを除外した、今年読了済みの書籍カウントの取得

**実装の要点**:
- `@this_year_books_read` を定義する。
- ユーザーに紐づく `books` のうち、`status: :completed` かつ `completed_at` が今年の範囲内にあるものをカウントする。
- 範囲取得には `Time.current.all_year` を使用する。

### 2. View (`app/views/dashboards/show.html.erb`)

**責務**:
- ユーザーのダッシュボード表示
- 年間目標の進捗割合・テキスト表示

**実装の要点**:
- 年間目標の進捗割合（`goal_percentage`）および進捗テキスト（分子の部分）で、`@total_books_read` の代わりに `@this_year_books_read` を参照する。

## テスト戦略

### 統合テスト (System Spec / Request Spec)

- `spec/system/dashboards_spec.rb` を調査し、必要に応じてテストケースを追加します。
- 今年読了した本と、前年（過去）に読了した本が存在する状態でダッシュボードにアクセスし、年間目標の進捗が正しく「今年読了した本の数のみ」になっていることを検証します。
- また、読書統計の「読了した本」には前年以前の本も含めた全期間の合計が表示されていることを検証します。

## ディレクトリ構造

```
app/
  controllers/
    dashboards_controller.rb
  views/
    dashboards/
      show.html.erb
spec/
  system/
    dashboards_spec.rb
```

## 実装の順序

1. コントローラーへの `@this_year_books_read` 追加
2. ビューの修正（`@total_books_read` から `@this_year_books_read` への置き換え）
3. テストの作成・実行（RSpec）
