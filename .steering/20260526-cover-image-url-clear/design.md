# 設計書

## 実装アプローチ

### 概要

Stimulus コントローラー（`book_form_controller.js`）に `clearCoverImageUrl` メソッドを追加し、ビューの file_field に `data-action` を追加して `change` イベントをハンドルする。

### 実装方針

#### 方針A: Stimulus action を使う（採用）

- コントローラーに `clearCoverImageUrl(event)` メソッドを追加する
- ビュー (`_form.html.erb`) の `f.file_field :cover_image` に `data-action: "change->book-form#clearCoverImageUrl"` を追加する

この方針は既存のStimulusパターンと一貫しており、宣言的で分かりやすい。

#### 方針B: connect() で addEventListener を使う（不採用）

- `connect()` 内で `document.getElementById('book_cover_image').addEventListener('change', ...)` を追加する
- Stimulusの宣言的なスタイルから外れるため不採用

### 変更ファイル

1. **`app/javascript/controllers/book_form_controller.js`**
   - `clearCoverImageUrl(event)` メソッドを追加
   - `document.getElementById('book_cover_image_url').value = ''` を実行

2. **`app/views/books/_form.html.erb`**
   - `f.file_field :cover_image` に `data: { action: "change->book-form#clearCoverImageUrl" }` を追加

### 注意点

- `cover_image_url` hidden フィールドのクリアは、ファイル選択時のみ行う
- auto-fetch（`_fillFormFromSearch`）はファイル入力をクリアしない（要件どおり）
- システムテスト（Capybara）でのカバーは難易度が高い（ファイルアップロードのモック）ため、既存のRSpecで対応可能な範囲のみテストする
