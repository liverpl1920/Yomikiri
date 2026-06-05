# 設計書

## アーキテクチャ概要

既存の Rails + Hotwire (Stimulus) アーキテクチャに則り、フロントエンド（Stimulus コントローラー）から既存のバックエンド検索エンドポイント（`/books/search?q=...`）を呼び出し、取得したデータを項目ごとに流し込む設計とします。

```
[Browser (HTML Form)] 
    │
    │ 1. 「補完」クリック (click->book-form#fetchSingleField)
    ▼
[book_form_controller.js]
    │
    │ 2. タイトルをキーに検索リクエスト (GET /books/search?q=...) ※キャッシュがなければ実行
    ▼
[BooksController#search] (Rails Backend)
    │
    │ 3. Google Books / openBD API よりデータ取得し JSON 返却
    ▼
[book_form_controller.js]
    │ 4. 検索結果 (books[0]) をキャッシュ保存
    │ 5. 対象フィールド (e.g. 著者) の value を上書き反映
    ▼
[Browser (HTML Form)] 画面上で対象フィールドが更新される
```

## コンポーネント設計

### 1. フロントエンドビュー (`app/views/books/_form.html.erb`)

**責務**:
- 「著者」「翻訳者」「ジャンル」「出版社」「ページ数」「書影画像」の入力欄の横に個別取得用の「補完」ボタンを表示する。

**実装の要点**:
- ボタンをインプットと横並びにするため、新しく `.form-field__input-row` クラスでラップし、インプットとボタンを格納する。
- ボタンには Stimulus アクション `data-action="click->book-form#fetchSingleField"` と、対象項目を識別するための `data-field="author"` などの `data-field` 属性を付与する。
- 書影画像セクションについては、ファイルのアップロードインプットの横または下部に「補完」ボタンを配置し、`data-field="cover"` を設定する。

### 2. Stimulus コントローラー (`app/javascript/controllers/book_form_controller.js`)

**責務**:
- 個別取得ボタンのクリックイベント（`fetchSingleField`）をハンドリングし、API 検索の実行と結果のキャッシュ制御を行う。
- 取得した書籍データから、指定されたフィールドのみを選択して対応する入力欄に上書き流し込みを行う。

**実装の要点**:
- `connect` メソッドで `this.cachedBook = null` を初期化する。
- `_performFetchByTitle` 内で、一括取得成功時に `this.cachedBook = book` とキャッシュに保存する処理を追加する。
- 新しく `fetchSingleField(event)` アクションを追加し、クリックされたボタンの `data-field` から対象を特定、タイトルが一致するキャッシュがなければAPI経由で取得し、`_fillSingleField(field, book)` を呼ぶ。
- `_fillSingleField(field, book)` は以下のように動作する：
  - `author`, `translator`, `publisher`, `genre`, `pages`, `cover` の各値を取得し、該当する input に流し込む。
  - すでに値が入っていても**上書き**する（個別取得の明示的指示のため）。
  - `pages`（ページ数）の更新時は、ノルマ計算を再度走らせるために `input` イベントを dispatch する。
  - `cover`（書影）の更新時は、`cover_image_url` に設定し、`_updateCoverPreview` を呼び出す。さらに、手動でファイルが選択されていた場合の競合を防ぐため、file input の値をクリアする。
  - 反映完了後、画面に「{項目名}を取得しました。」または「{項目名}の情報は見つかりませんでした。」と status 表示（`this.titleStatusTarget`）を出す。

### 3. スタイルシート (`app/assets/stylesheets/books.css`)

**責務**:
- 横並びレイアウト（`.form-field__input-row`）と、小サイズボタン（`.btn--sm`）の定義。

**実装の要点**:
- `books.css` に `.form-field__input-row` を追加する。
  ```css
  .form-field__input-row {
    display: flex;
    align-items: center;
    gap: var(--spacing-sm);
  }
  .form-field__input-row .form-field__input {
    flex: 1;
  }
  .form-field__input-row .form-field__input--narrow {
    flex: initial;
  }
  .btn--sm {
    padding: 0.5rem 1rem;
    font-size: var(--font-size-sm);
    flex-shrink: 0;
  }
  ```

## エラーハンドリング戦略

- タイトルが未入力の場合：
  - APIリクエストを送信せず、`this._setTitleStatus('タイトルを入力してください。')` を表示して処理を中断する。
- APIリクエストが失敗した場合（ネットワークエラー等）：
  - `this._setTitleStatus('取得中にエラーが発生しました。')` を表示する。
- 該当する情報が存在しない場合：
  - `this._setTitleStatus('{項目名}の情報は見つかりませんでした。')` を表示する。

## テスト戦略

### ユニットテスト（Stimulus コントローラー / システムテスト）
- フロントエンドの動的な振る舞いと、ボタンのクリックによる値の反映は、システムテスト（System Specs）で検証します。

### 統合テスト（System Specs）
- `spec/system/books/book_form_feedback_spec.rb`（または新規の `spec/system/books/book_form_single_field_fetch_spec.rb`）にテストシナリオを追加する。
  - タイトルが空の状態で個別取得ボタン（例: 著者補完）を押した際、エラーメッセージ「タイトルを入力してください。」が表示されること。
  - タイトルが入力された状態で著者補完ボタンを押した際、APIのモックが呼び出され、著者入力欄に正しい著者名が補完され、ステータスに「著者を取得しました。」と表示されること。
  - キャッシュ動作の検証：一度著者補完を実行した後に、ページ数補完ボタンを押した際、モックのAPIコールが2回目は行われず、ページ数が即座に補完されること。
  - ページ数補完の完了時、今日のノルマ表示が自動的に更新されること。
  - 書影画像補完の完了時、書影プレビューが表示され、ファイル選択フォームがクリアされること。

## ディレクトリ構造

```
app/
├── assets/
│   └── stylesheets/
│       └── books.css (変更)
├── javascript/
│   └── controllers/
│       └── book_form_controller.js (変更)
└── views/
    └── books/
        └── _form.html.erb (変更)
spec/
└── system/
    └── books/
        └── book_form_single_field_fetch_spec.rb (新規)
```

## 実装の順序

1. `app/assets/stylesheets/books.css` に横並び用と小ボタン用のスタイルを追加する。
2. `app/views/books/_form.html.erb` に個別取得用の「補完」ボタンを追加し、横並びのレイアウトに修正する。
3. `app/javascript/controllers/book_form_controller.js` を拡張し、キャッシュ処理と `fetchSingleField`、`_fillSingleField` を実装する。
4. 手動および System Specs での検証（モックを使用したテスト）を実施する。
