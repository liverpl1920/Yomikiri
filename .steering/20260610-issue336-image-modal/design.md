# 設計書

## アーキテクチャ概要

本機能は、Rails 7.2 のフロントエンド規約である Hotwire エコシステムに従い、HTML5 `<dialog>` タグと Stimulus コントローラーを用いて実装します。CSSはTailwind CSSを用いず、既存のBEM規約に基づきVanilla CSSで記述します。

```
[View: show.html.erb] --(click)--> [Stimulus: image-modal-controller] --(showModal())--> [HTML5 <dialog>]
                                                                                         |
                                                                                    ( backdrop / close-button )
                                                                                         |
[View: show.html.erb] <-----------(close())----------------------------------------------┘
```

## コンポーネント設計

### 1. View: `app/views/books/show.html.erb`
**責務**:
- 書影画像をクリック可能にし、拡大モーダル `<dialog>` 要素を埋め込む。

**実装の要点**:
- 書影画像を `data-controller="image-modal"` の配下に置き、画像要素に `data-action="click->image-modal#open"` を付与する。
- 拡大用モーダルとして `<dialog data-image-modal-target="dialog">` を定義する。
- `dialog` 内に拡大用の `img` タグと「✕」ボタンを配置する。

### 2. Stimulus Controller: `app/javascript/controllers/image_modal_controller.js`
**責務**:
- `<dialog>` の表示 (`showModal()`) と非表示 (`close()`) を制御する。
- モーダル表示中の背景スクロールを制御する（`document.body.style.overflow = 'hidden'`）。

**実装の要点**:
- HTML5 `<dialog>` 要素を `dialogTarget` として参照する。
- `click` イベントがバブリングするため、背景 (`::backdrop`) のクリックは `event.target === this.dialogTarget` で判定してモーダルを閉じる。

### 3. Stylesheet: `app/assets/stylesheets/books.css`
**責務**:
- 書影画像のホバー効果およびポインタ表示（`cursor: pointer`）。
- `<dialog>` のレイアウトとスタイル（`::backdrop` の暗転、中央表示など）を定義する。

**実装の要点**:
- BEM記法に従い、`.image-modal-dialog` や `.image-modal-dialog__container` のように定義する。

## データフロー

### 書影モーダル開閉
```
1. ユーザーが書影をクリック
2. image-modal-controller#open が実行され、dialog.showModal() が呼び出される
3. 同時に body 要素の overflow が 'hidden' に設定されスクロール不可になる
4. ユーザーが「✕」または背景（backdrop）をクリック
5. image-modal-controller#close が実行され、dialog.close() が呼び出される
6. 同時に body 要素の overflow が解除される
```

## テスト戦略

### システムスペック (System Spec)
`spec/system/books_spec.rb`（または適切なSystem Specファイル）にテストケースを追加します。
- 詳細画面で書影をクリックしたとき、モーダルが表示されること。
- モーダル内の「✕」をクリックしたとき、モーダルが閉じること。
- モーダルの背景をクリックしたとき、モーダルが閉じること。

## ディレクトリ構造

```
app/
├── javascript/
│   └── controllers/
│       └── image_modal_controller.js  [NEW]
└── assets/
    └── stylesheets/
        └── books.css                  [MODIFY]
app/views/
└── books/
    └── show.html.erb                  [MODIFY]
spec/system/
└── books_spec.rb                      [MODIFY]
```

## 実装の順序

1. **ブランチの作成**: `feature/#336-image-modal` の作成
2. **JavaScript 実装**: Stimulus `image_modal_controller.js` の新規作成
3. **HTML 実装**: `show.html.erb` にモーダル `<dialog>` を埋め込み、Stimulusのアクションとターゲットをアタッチ
4. **CSS 実装**: `books.css` にポインタおよびモーダル用のスタイルを追加
5. **テスト追加**: システムスペックで動作確認の自動テストを追加
6. **動作検証**: RSpecとRuboCopでテストと静的チェックを実行

## セキュリティ考慮事項

- HTML5の `<dialog>` を使用し、表示時のフォーカストラップなどはブラウザ標準のアクセシビリティ・セキュリティ機能に準拠する。

## パフォーマンス考慮事項

- 拡大用画像は既に詳細画面にロードされている同じ `book_cover_src(@book)` のURLを使用するため、新たな重い画像転送は発生しない（ブラウザキャッシュを利用）。
