# 設計書: 一覧画面にジャンル情報を表示する

## 実装アプローチ

### 表示方針
- `app/views/books/index.html.erb` の書籍カード（`.book-card__body`）に、著者名の直下にジャンルタグを追加する
- `book.genre.present?` の場合のみ表示（未設定時は非表示）
- スタイルは既存のステータスバッジ（`.book-card__status`）に倣い、小さなタグ形式で表示する

### CSS設計
- クラス名: `.book-card__genre`
- 色: グレー系（ニュートラルトーン、読書分類情報として目立ちすぎない）
- サイズ: `font-size: 0.75rem`、ステータスバッジと同等

### テスト方針
- `spec/system/books/` にジャンル表示のシステムスペックを追加
- ジャンルあり書籍: ジャンルが表示されることを確認
- ジャンルなし書籍: ジャンルが表示されないことを確認

## ファイル変更計画

| ファイル | 変更内容 |
|---------|---------|
| `app/views/books/index.html.erb` | 著者名下にジャンルタグを追加 |
| `app/assets/stylesheets/books.css` | `.book-card__genre` スタイル追加 |
| `spec/system/books/genre_display_spec.rb` | ジャンル表示のシステムスペック追加 |
