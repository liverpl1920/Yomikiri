# 設計書

## アーキテクチャ概要

評価表示は `app/views/books/index.html.erb` が担当しているため、まずは一覧の描画経路を確認する。評価更新後に古い表示が残る場合は、表示側のキャッシュや再取得タイミングを最小差分で調整する。

```
BooksController#index
  └─ current_user.books.filtered_for_index(...)
       └─ app/views/books/index.html.erb
            └─ book.rating を元に星表示
```

## 方針

### 1. 再現テストを先に追加する
- 評価更新後に一覧へ戻ったとき、保存済みの評価と星数が一致することを system spec で確認する
- 1点・4点・5点のような境界値も含めて、星数のズレが起きないことを担保する

### 2. 表示の最小修正を行う
- 一覧の評価表示が最新値を参照するようにする
- 必要であれば、一覧ページの Turbo キャッシュを無効化する、または評価表示の描画条件を整理する
- 修正は books 一覧の表示経路に限定する

### 3. 回帰確認を行う
- 既存の一覧表示テストと評価更新テストを通して、ソートや他項目に影響がないことを確認する

## テスト戦略

### System Spec
- 評価を更新したあと、一覧に戻って星表示が更新されていることを確認する
- completed / rating nil / rating 1 / rating 5 の表示差分を確認する

### Request Spec
- 既存の一覧評価表示テストを確認し、必要なら評価更新後の一覧表示テストを追加する

## 想定変更ファイル

- `app/views/books/index.html.erb`
- `spec/system/books/books_crud_spec.rb` または `spec/requests/books_spec.rb`
