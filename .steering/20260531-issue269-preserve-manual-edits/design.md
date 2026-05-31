# 設計書

## アーキテクチャ概要

クライアントサイドのStimulusコントローラー修正。サーバー側の変更なし。

```
book_form_controller.js
  └─ _fillFormFromSearch()
       ├─ author    → 空の場合のみ自動入力（修正）
       ├─ genre     → 空の場合のみ自動入力（修正）
       ├─ total_pages → 空の場合のみ自動入力（修正）
       ├─ cover_image_url → 変更なし（submitWithAutoFetchで保護済み）
       └─ isbn      → 変更なし（空の場合のみ既存動作を継続）
```

## コンポーネント設計

### 1. `_fillFormFromSearch` (book_form_controller.js)

**責務**:
- APIから取得した書籍情報をフォームへ反映する
- ユーザーが手動入力済みのフィールドは上書きしない

**修正方針**:
- 各フィールドへの代入前に「現在の値が空かどうか」を確認する
- 空の場合のみAPIの値を代入する

**修正例**:
```js
// Before
if (authorInput && author) {
  authorInput.value = author
} else {
  missing.push('著者')
}

// After
if (authorInput && author) {
  if (!authorInput.value.trim()) {
    authorInput.value = author
  }
} else {
  missing.push('著者')
}
```

同様に genre / total_pages も空の場合のみ上書きする。

## データフロー

### 修正後の自動取得フロー
```
1. ユーザーがタイトル入力 or フォーム送信
2. _performFetchByTitle() でAPIコール
3. _fillFormFromSearch(book) 呼び出し
4. 各フィールドについて:
   - 既に値が入っている → スキップ（手動入力を保護）
   - 空 → APIの値を自動入力
5. ステータスメッセージ更新
```

## テスト戦略

### システムテスト (RSpec/Capybara)
- `spec/system/books/book_form_feedback_spec.rb` に追加:
  - ジャンル手動入力後にautoFetchが実行されても値が保持されることを確認
  - 総ページ数手動入力後にautoFetchが実行されても値が保持されることを確認
  - フィールドが空のときはAPIの値で自動入力されることを確認

## ディレクトリ構造

変更対象:
```
app/javascript/controllers/book_form_controller.js  ← メイン修正
spec/system/books/book_form_feedback_spec.rb        ← テスト追加
```
