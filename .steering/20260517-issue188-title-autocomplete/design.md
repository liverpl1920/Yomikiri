# Design: タイトル入力中オートコンプリート機能 (Issue #188)

## 実装アプローチ

### 方針
既存の `book_form_controller.js` と `book_search_controller.js` のパターンを踏まえ、
新しい Stimulus コントローラ `title_autocomplete_controller.js` を作成する。
既存コードを極力変更せず、機能を新コントローラに閉じ込める。

### コンポーネント構成

```
app/javascript/controllers/title_autocomplete_controller.js  ← 新規
app/views/books/_form.html.erb                               ← 修正（autocomplete要素追加）
app/assets/stylesheets/books.css                             ← 修正（autocomplete CSS追加）
spec/system/books/title_autocomplete_spec.rb                 ← 新規（system spec）
```

### Stimulusコントローラ設計 (`title_autocomplete_controller.js`)

**targets:**
- `input`: タイトル入力欄
- `list`: 候補表示リスト（ul要素）

**状態:**
- `debounceTimer`: debounce用タイマーID
- `activeIndex`: 現在フォーカスされている候補のインデックス
- `candidates`: 取得した候補配列

**actions:**
- `onInput(event)`: debounce付きで検索APIを呼び出し
- `onKeydown(event)`: 上下/Enter/Esc キー処理
- `selectCandidate(book)`: 候補選択 → フォーム補完 + ドロップダウン閉じる
- `_fetchCandidates(query)`: `/books/search?q=...` を呼び出し
- `_renderList(books)`: 候補リストをDOMに描画
- `_closeList()`: ドロップダウンを閉じる
- `_fillForm(book)`: 既存パターンに従いフォームを補完

**フォーム補完ロジック (`_fillForm`):**
- `book_title` → book.title
- `book_author` → book.author
- `book_total_pages` → book.total_pages（+ `input` イベント dispatch）
- `book_cover_image_url` → book.cover_image_url
- `book-form` コントローラの `coverPreview` と `titleStatus` も更新

### フォームHTML変更点 (`_form.html.erb`)

タイトル入力欄に以下のdata属性を追加:
```html
data-controller="title-autocomplete"
data-action="input->title-autocomplete#onInput keydown->title-autocomplete#onKeydown"
data-title-autocomplete-target="input"
```

タイトルフィールド直下にdropdownリストを追加:
```html
<ul class="title-autocomplete__list title-autocomplete__list--hidden"
    data-title-autocomplete-target="list"
    role="listbox"></ul>
```

### CSS設計 (`books.css`)

BEM命名規則:
```
.title-autocomplete__list         ← ドロップダウンコンテナ
.title-autocomplete__list--hidden ← 非表示状態
.title-autocomplete__item         ← 各候補行
.title-autocomplete__item--active ← アクティブ状態
.title-autocomplete__button       ← クリック可能ボタン
.title-autocomplete__cover        ← 書影サムネイル
.title-autocomplete__info         ← タイトル・著者テキスト
.title-autocomplete__title        ← タイトル
.title-autocomplete__author       ← 著者
```

### デバウンス
- 300ms delay
- 入力値が2文字未満の場合はリストを閉じる

### キーボード操作
- `ArrowDown`: 次の候補にフォーカス移動
- `ArrowUp`: 前の候補にフォーカス移動
- `Enter`: フォーカス中の候補を選択（ドロップダウン表示中のみ）
- `Escape`: ドロップダウンを閉じる

### 既存フローとの整合性
- `blur->book-form#autoFetchByTitle` は維持（フォーカスアウト時にフォーム補完）
- オートコンプリートで選択した場合は `book-form` の `lastAutoFetchedTitle` を更新して二重呼び出しを防ぐ
