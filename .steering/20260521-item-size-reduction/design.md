# 設計: 書影アイテムサイズ縮小 (ISSUE#203)

## アプローチ

CSSのみの変更で対応する。Rubyコードへの変更は不要。

## 対象ファイル

- `app/assets/stylesheets/books.css` のみ

## 変更内容

### 1. 積読一覧グリッド (`.book-list`)

**現状**:
```css
.book-list {
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
}
```

**変更後**:
```css
.book-list {
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
}
```

- `280px → 200px` に縮小
- 1行あたりの表示枚数が増え、各カードが小さく表示される
- 画質の粗さが目立ちにくくなる

### 2. 書籍カードプレースホルダーフォントサイズ (`.book-card__cover-placeholder`)

**現状**:
```css
.book-card__cover-placeholder {
  font-size: 4rem;
}
```

**変更後**:
```css
.book-card__cover-placeholder {
  font-size: 3rem;
}
```

- カードが小さくなるのに合わせてプレースホルダーアイコンも縮小

### 3. レスポンシブ対応

モバイル（640px以下）では引き続き `grid-template-columns: 1fr` の設定を維持。
縮小後も視認性を損なわないようにする。

## 非変更項目

- `books/show.html.erb` の `.book-show__cover-wrapper`（width: 120px）は既に小さいため変更不要
- ビューファイル（HTML）への変更なし
- Rubyモデル・コントローラへの変更なし
- テストコードへの変更なし
