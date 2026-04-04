# タスクリスト: 積読詳細表示機能 (Issue #16)

## フェーズ1: View実装

- [x] show.html.erb: ステータスバッジを追加
- [x] show.html.erb: 進捗プログレスバーを追加
- [x] show.html.erb: 残ページ数を追加
- [x] show.html.erb: 延長回数を追加
- [x] show.html.erb: 「今日のノルマ」を削除（後続Issue対応）
- [x] index.html.erb: book-cardをlink_toに変更（書籍詳細リンク化）

## フェーズ2: CSS実装

- [x] books.css: book-showコンポーネントCSSを追加

## フェーズ3: テスト

- [x] spec/requests/books_spec.rb: showページにステータス表示のテストを追加
- [x] spec/requests/books_spec.rb: showページに進捗プログレスバーのテストを追加
- [x] spec/requests/books_spec.rb: showページに残ページ数・延長回数のテストを追加

## 実装後の振り返り

- 実装完了日: 2026-04-04
- 計画と実績の差分: 計画通り全タスク完了。追加変更なし。
- 学んだこと: index.html.erbのコメント「Issue #16実装後に変更」が明示されており、既存コードとの整合性が保たれていた。
- 次回への改善提案: なし
