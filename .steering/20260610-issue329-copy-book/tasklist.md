# タスクリスト: 書籍コピー再登録機能の実装

- [x] 新しいブランチを作成する
  - [x] `git switch main`
  - [x] `git pull origin main`
  - [x] `git switch -c feature/#329-copy-book`
- [x] コントローラーの実装 (`app/controllers/books_controller.rb`)
  - [x] `new` アクションで `copy_from_id` が渡された際に、書籍データを複製しリセット処理、およびアタッチメントのコピーを行うよう実装する
- [x] ビューの実装 (`app/views/books/show.html.erb`)
  - [x] 詳細画面のボタン群に「この本をもう一度読む」リンクを追加する
- [x] テストの追加
  - [x] リクエストスペック (`spec/requests/books_spec.rb`) に `GET /books/new` での複製機能のテストケース（自分、他人、存在しない、アタッチメントあり）を追加する
  - [x] システムスペック (`spec/system/books/books_crud_spec.rb`) に画面遷移と登録完了の一連のシナリオを追加する
- [x] 検証
  - [x] RSpecを実行し、すべてのテストがパスすることを確認する
  - [x] RuboCopを実行し、規約違反がないことを確認する
  - [x] Brakeman を実行し、セキュリティ警告がないことを確認する
- [x] 完了報告
