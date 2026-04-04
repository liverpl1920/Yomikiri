# 設計

## 実装アプローチ

### ルーティング
`resources :books` に `destroy` を追加:
```ruby
resources :books, only: [ :index, :new, :create, :show, :destroy ]
```

### コントローラ（BooksController#destroy）
```ruby
before_action :set_book, only: [ :show, :destroy ]

def destroy
  @book.destroy
  redirect_to books_path, notice: "#{@book.title}を削除しました。"
end
```

### モーダル実装方針

Stimulus.js と HTML の `<dialog>` 要素またはネイティブ CSS モーダルを使う。  
既存の JavaScript 構成（Importmap + Stimulus）を活用し、新たな依存を追加しない。

- `data-controller="modal"` の Stimulus コントローラーを作成
- `data-action="click->modal#open"` で削除ボタンからモーダルを開く
- `data-action="click->modal#close"` でキャンセルボタンからモーダルを閉じる
- モーダル内の削除フォームは Rails の `button_to` で `DELETE` リクエストを送信

### ビュー構成

`app/views/books/show.html.erb` に:
1. 「削除する」ボタン（`data-action="click->modal#open"`）
2. モーダルHTML（`data-modal-target="overlay"`）
3. モーダル内に確認メッセージ・書籍名・削除フォーム・キャンセルボタン

### CSS
- `.modal-overlay` クラスで背景オーバーレイ
- `.modal` クラスでモーダルコンテナ
- `hidden` 属性を使った表示/非表示の切替（Stimulus で `hidden` 属性をトグル）

## ファイル変更一覧

| ファイル | 変更種別 | 概要 |
|---------|---------|------|
| `config/routes.rb` | 変更 | booksリソースに`:destroy`を追加 |
| `app/controllers/books_controller.rb` | 変更 | destroyアクションと`before_action`追加 |
| `app/views/books/show.html.erb` | 変更 | 削除ボタンとモーダルHTMLを追加 |
| `app/javascript/controllers/modal_controller.js` | 新規 | Stimulusモーダルコントローラ |
| `app/assets/stylesheets/books/show.scss` または既存CSS | 変更 | モーダルのスタイル追加 |
| `spec/requests/books_spec.rb` | 変更 | destroyアクションのテスト追加 |
