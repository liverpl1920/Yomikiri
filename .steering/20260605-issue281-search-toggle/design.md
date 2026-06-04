# 設計書

## アーキテクチャ概要

本機能はRailsのビュー、CSS (BEM)、およびStimulusコントローラを組み合わせて実装します。

```
[ビュー (index.html.erb)] 
  └── search-toggle (Stimulus Controller)
        ├── target: button (トグルボタン)
        └── target: form (検索フォーム)
```

## コンポーネント設計

### 1. ビュー / CSS

#### [MODIFY] [index.html.erb](file:///home/ippei/runteq/graduation_work/Yomikiri/app/views/books/index.html.erb)
- 検索フォームおよびトグルボタンを制御するStimulusのコントローラをバインドします。
- タイトル右側にトグルボタン「検索」と「+ 本を追加する」を横並びにするため、`.books-index__header-actions` ラッパーを導入します。
- アクセシビリティのため、トグルボタンに `aria-expanded`, `aria-controls` を設定します。

#### [MODIFY] [books.css](file:///home/ippei/runteq/graduation_work/Yomikiri/app/assets/stylesheets/books.css)
- 検索フォーム非表示用のモディファイアクラスを追加します。
  - `.books-index__search--hidden` { display: none !important; }
- ヘッダーのアクション領域用に以下のスタイルを追加します。
  - `.books-index__header-actions`
- トグルボタン専用のスタイルを追加する（必要に応じて `books-index__search-toggle-btn` など）。

### 2. Stimulus コントローラ

#### [NEW] [search_toggle_controller.js](file:///home/ippei/runteq/graduation_work/Yomikiri/app/javascript/controllers/search_toggle_controller.js)
- **責務**:
  - 検索フォームの表示・非表示のトグル。
  - 状態（`aria-expanded`, 非表示クラス）の同期。
- **実装の要点**:
  - `activeValue` (Boolean) を持ち、初期値はビュー側の `@search_active` から受け取る。
  - `activeValue` の値変更を監視し、`activeValueChanged()` 内で非表示クラス `.books-index__search--hidden` のトグルと、ボタンの `aria-expanded` の更新を行う。

## データフロー

### 初期表示（検索条件なし）
1. ユーザーが `/books` にアクセス。
2. コントローラで `@search_active` が `false` と判定される。
3. HTMLレンダリング時、`data-search-toggle-active-value="false"` となる。
4. Stimulusの `connect()` が走り、検索フォームに `books-index__search--hidden` クラスが付与される。

### ボタン押下によるトグル
1. ユーザーが「検索」ボタンをクリック。
2. `search-toggle#toggle` が呼び出され、`activeValue` が反転する。
3. `activeValueChanged()` がトリガーされ、非表示クラスが除去（または追加）され、`aria-expanded` が `true`（または `false`）に更新される。

## テスト戦略

### システムテスト
- `spec/system/books/search_toggle_spec.rb` を作成。
- 以下のシナリオを検証します：
  - 初期状態で検索フォームが非表示であること。
  - トグルボタン押下で表示/非表示が切り替わること。
  - 検索条件（例: `?title=ruby`）が含まれる場合、初期状態で表示されていること。

## ディレクトリ構造

```
app/
 ├── assets/
 │    └── stylesheets/
 │         └── books.css (修正)
 ├── javascript/
 │    └── controllers/
 │         └── search_toggle_controller.js (新規作成)
 └── views/
      └── books/
           └── index.html.erb (修正)
spec/
 └── system/
      └── books/
           └── search_toggle_spec.rb (新規作成)
```

## 実装の順序

1. `books.css` のスタイル追加
2. `search_toggle_controller.js` の新規作成
3. `index.html.erb` のマークアップ修正
4. `search_toggle_spec.rb` の作成とテスト実行
