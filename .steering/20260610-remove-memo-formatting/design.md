# 設計書

## アーキテクザ概要
既存のメモ装飾用ロジックとビューのコントロールをすべて取り除き、シンプルなプレーンテキスト処理に一本化します。

## コンポーネント設計

### 1. `BookMemosHelper`
- **修正ファイル**: `app/helpers/book_memos_helper.rb`
- **内容**:
  - `render_book_memo_content` メソッドから `BOLD_PATTERN`, `COLOR_PATTERN` および `gsub` による HTML タグ変換ロジックをすべて削除します。
  - 以下のようにシンプルな実装に変更します。
    ```ruby
    def render_book_memo_content(content)
      simple_format(content.to_s)
    end
    ```
    ※ `simple_format` は内部で `html_escape` を自動的に実行するため、別途のエスケープ処理や `sanitize: false` は不要になります。

### 2. ビュー (`views`)
- **修正ファイル**:
  - `app/views/books/show.html.erb`
  - `app/views/book_memos/edit.html.erb`
  - `app/views/book_memos/create.turbo_stream.erb`
- **内容**:
  - `form_with` オプションから `data: { controller: 'memo-format' }` を削除。
  - 装飾ツールバーのコンポーネント部分（`<div class="book-show__memo-toolbar" ...> ... </div>`）を削除。
  - メモ入力用の `f.text_area` から `data: { memo_format_target: 'textarea' }` の属性を削除。
  - ヘルプテキスト `<small>` 内の説明文から「（太字: **テキスト** / 色: [color=#ff0000]テキスト[/color]）」の記述を削除し、「最大2000文字」のみにします。

### 3. Stimulus コントローラー
- **削除ファイル**: `app/javascript/controllers/memo_format_controller.js`
- **内容**: コントローラーファイルを物理削除します。プロジェクトの Javascript ロード（`eagerLoadControllersFrom`）は自動でファイル走査を行うため、削除するだけで反映されます。

### 4. テスト設計
- **修正ファイル**: `spec/helpers/book_memos_helper_spec.rb`
- **内容**:
  - `太字記法をstrongタグに変換する` テスト -> 変換せず、そのままプレーンテキストで出力されることの確認に変更。
  - `色記法をspan styleに変換する` テスト -> 変換せず、そのままプレーンテキストで出力されることの確認に変更。
  - `許可外HTMLをエスケープする` テスト -> `simple_format` によって正しくエスケープされることの確認。

## ディレクトリ構造
```text
app/helpers/book_memos_helper.rb
app/views/books/show.html.erb
app/views/book_memos/edit.html.erb
app/views/book_memos/create.turbo_stream.erb
app/javascript/controllers/memo_format_controller.js  (DELETE)
spec/helpers/book_memos_helper_spec.rb
```

## 実装の順序
1. `BookMemosHelper` の修正および `book_memos_helper_spec.rb` テストの修正・パス確認。
2. `books/show.html.erb`、`book_memos/edit.html.erb`、`book_memos/create.turbo_stream.erb` のビュー修正。
3. `memo_format_controller.js` の削除。
4. 全体テスト (`bundle exec rspec`) および `rubocop` の実行。
