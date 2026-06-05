# Issue #305 設計

## 問題の根本原因

`fetchSingleField` がキャッシュ未存在時に `_fetchBookByTitle(title)` を呼び出す。
`_fetchBookByTitle` は内部で `_performFetchByTitle` を呼び出すが、この関数は
`_fillFormFromSearch(book)` を無条件で実行する。

これは「情報取得」ボタン（一括補完）との共通処理であり、個別補完の場合でも
全フィールドを自動入力してしまう。

## 修正方針

`_performFetchByTitle` および `_fetchBookByTitle` に `fillForm` オプションを追加する。

- `fillForm: true`（デフォルト）：従来の一括入力処理を実行（「情報取得」ボタンから使用）
- `fillForm: false`：データ取得のみ行い、フォームへの反映は行わない（個別補完から使用）

`fetchSingleField` の内部では `_fetchBookByTitle(title, { fillForm: false })` を呼ぶ。

## 修正箇所

### `_fetchBookByTitle`

```javascript
async _fetchBookByTitle (title, { fillForm = true } = {}) {
  if (this.fetchPromise && this.fetchingTitle === title) {
    await this.fetchPromise
    return true
  }

  this.fetchingTitle = title
  this.fetchPromise = this._performFetchByTitle(title, { fillForm })

  try {
    return await this.fetchPromise
  } finally {
    this.fetchPromise = null
  }
}
```

### `_performFetchByTitle`

```javascript
async _performFetchByTitle (title, { fillForm = true } = {}) {
  // ... API取得処理 ...
  const book = books[0]
  this.cachedBook = book

  if (fillForm) {
    const missing = this._fillFormFromSearch(book)
    const coverUrlInput = document.getElementById('book_cover_image_url')
    this._updateCoverPreview(coverUrlInput ? coverUrlInput.value : '')
    this._setTitleStatus(this._buildFetchResultMessage(missing))
  }
  return true
}
```

### `fetchSingleField`

```javascript
async fetchSingleField (event) {
  // ...
  if (!book || this.fetchingTitle !== title) {
    const success = await this._fetchBookByTitle(title, { fillForm: false })
    // ...
  }
  // ...
}
```

## テスト追加方針

`book_form_single_field_fetch_spec.rb` に以下のテストケースを追加：

- キャッシュなし状態で個別補完を実行した際、他の項目が自動入力されないことを確認
