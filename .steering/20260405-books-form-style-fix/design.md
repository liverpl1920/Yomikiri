# 設計: 積読登録フォームのスタイル修正

## 実装アプローチ

`app/assets/stylesheets/books.css` に不足している CSS クラスを追加する。
テンプレートのクラス名は変更しない（HTML側は修正不要）。

## 参考スタイル

`auth.css` で定義済みの `.form-group` / `.form-label` / `.form-input` を参考に、
`form-field__` プレフィックスを持つ BEM バリエーションとして実装する。

## CSS設計の方針

### デザイントークン（CSS カスタムプロパティ）の使用
`application.css` で定義された以下のカスタムプロパティを使用:
- カラー: `--color-primary`, `--color-text`, `--color-text-muted`, `--color-border`, `--color-danger`, `--color-bg`, `--color-bg-surface`
- スペーシング: `--spacing-xs`, `--spacing-sm`, `--spacing-md`, `--spacing-lg`, `--spacing-xl`
- フォントサイズ: `--font-size-sm`, `--font-size-base`, `--font-size-lg`
- ボーダー: `--border-radius`, `--border-radius-lg`

### 追加するセクション構成

1. **ページヘッダー** (`page-header`, `page-header__title`, `page-header__description`)
   - `.book-form-wrapper` の前に表示するタイトルとサブタイトル部分

2. **フォームラッパー** (`book-form-wrapper`)
   - フォームの最大幅・中央配置

3. **フォームフィールド** (`form-field` BEMコンポーネント)
   - `form-field`: コンテナ（flex, column方向, gap付き）
   - `form-field__label`: ラベル
   - `form-field__required` / `form-field__optional`: 必須/任意バッジ
   - `form-field__input`: インプットフィールド（auth.cssのform-inputと同等）
   - `form-field__input--narrow`: 幅制限付きインプット（ページ数用）
   - `form-field__input--date`: 日付インプット
   - `form-field__input--error`: エラー時スタイル
   - `form-field__error`: エラーメッセージ
   - `form-field__hint`: ヒントテキスト
   - `form-field__unit`: 入力単位テキスト（"ページ"など）

4. **フォームエラー** (`form-errors` BEMコンポーネント)
   - バリデーションエラー一覧の表示エリア

5. **フォームアクション** (`form-actions`)
   - ボタン並びのレイアウト

6. **ノルマプレビュー** (`quota-preview` BEMコンポーネント)
   - 今日のノルマ（目安）表示エリア

## 実装上の注意
- 既存の `books.css` のスタイル（書籍一覧、書籍詳細）は変更しない
- `books.css` の末尾に新規セクションを追加する
- BEM命名規則を守る
- `auth.css` との重複を避け、`books.css` 内で完結させる
