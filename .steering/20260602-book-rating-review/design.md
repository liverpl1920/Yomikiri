# 設計書 (Design)

## 1. データベース設計

`books` テーブルに以下のカラムを追加する。

| カラム名 | 型      | 制約         | 説明             |
| :------- | :------ | :----------- | :--------------- |
| `rating` | integer | 1〜5         | 書籍の評価（星） |
| `review` | text    | max 2000文字 | 書籍の感想       |

- `memo` カラム（既存）は「読書中のメモ」として維持し、今回の「読了後の感想」とは用途を明確に分ける。

## 2. 実装方針

### a. 読了フローの変更

- `books/show.html.erb` の「読了お祝いモーダル」内に、評価（★）と感想（textarea）の入力フォームを設置する。
- ユーザーが感想を入力して「保存する」ボタンを押すと、`books#update_review` (仮) または `books#update` に PATCH リクエストを送る。
- 保存成功後、一覧画面にリダイレクト、またはモーダルのみ閉じる。

### b. 評価入力UI (Rating UI)

- ラジオボタンとラベルを用いたCSSによる星評価UI（クリックで★1〜★5を選択）を導入する。
- `app/assets/stylesheets/rating.css` (または `books.css` 内) にスタイルを定義。

### c. 表示

- `books/show.html.erb` で、読了済みの書籍の場合に評価と感想を表示するセクションを追加する。
- 本の一覧画面（`books/index.html.erb`）でも星を表示するか検討（今回は要件に「詳細画面等で確認できる」とあるため、まずは詳細に集中）。

## 3. UI/UX 変更点

- **書籍詳細画面 (W-6)**:
  - 読了済みの場合、達成日・日数に加えて評価と感想を表示。
- **読了お祝いモーダル (W-13)**:
  - お祝いメッセージの後に、入力フォームを追加。
  - 「保存して一覧に戻る」と「保存せずに一覧に戻る」を選択可能にする。

## 4. ルーティング

```ruby
resources :books do
  member do
    patch :update_progress
    patch :update_memo
    patch :complete
    patch :change_deadline
    patch :update_review # 新設
  end
end
```
