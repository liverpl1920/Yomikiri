# 要求仕様 - 書影画像の解像度改善 (Issue #181)

## 概要

書籍の書影画像の解像度が低くなっているため、複数のAPIソースを最適化し、より高解像度な画像を取得・表示する改善を行います。

## 要求内容

### 1. Google Books API の複数サイズ対応
- `thumbnail` だけでなく、より大きいサイズ（`small`, `medium`, `large`, `extraLarge`）を優先使用する
- 利用可能な最大サイズを取得するロジックを実装

### 2. API優先順序の見直し
- 現在: openBD → Rakuten → Google Books thumbnail
- 改善後: openBD → Rakuten largeImageUrl → Google Books large/medium/small/thumbnail

### 3. openBD API の高解像度版対応確認
- openBD API が提供する cover URL を確認
- 現状提供される URL をそのまま使用（サイズバリエーションは未提供のため）

### 4. CSS と画像表示の最適化
- 高密度ディスプレイ（2x, 3x）への対応
- `image-rendering` プロパティの最適化

### 5. テスト更新
- 既存テスト（spec/requests/books_spec.rb）のモックを新しいサイズ取得ロジックに合わせて更新
- Google Books の imageLinks に複数サイズが含まれる場合のテストケースを追加

## 実装対象ファイル

- `app/controllers/books_controller.rb`
- `app/assets/stylesheets/books.css`
- `spec/requests/books_spec.rb`

## 非機能要件

- 既存のAPIアクセスパターン（openBD, Rakuten, Google Books）を維持
- 既存テストをすべてパスさせる
