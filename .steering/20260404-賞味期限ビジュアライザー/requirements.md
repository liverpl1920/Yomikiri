# 要求定義: 賞味期限ビジュアライザー機能 (Issue #23)

## 概要

期限が近い本ほど書影が色褪せるCSSエフェクトの実装。

## 対応画面

- W-4（積読一覧）: `app/views/books/index.html.erb`
- W-6（書籍詳細）: `app/views/books/show.html.erb`

## 実装内容

- deadline までの残り日数に応じて、書影（またはカード）にCSSエフェクトを適用する
  - 7日以下：セピア/透明度 弱（filter: sepia(0.3) opacity(0.9)相当）
  - 3日以下：セピア/透明度 中（filter: sepia(0.6) opacity(0.7)相当）
  - 1日以下：セピア/透明度 強（filter: sepia(0.9) opacity(0.5)相当）
- 一覧画面で視覚的に「どの本が緊急か」が即座に分かるようにする
- 期限超過の書籍にも適切なビジュアルを適用する

## 完了条件

- 残り日数に応じた3段階のCSS変化が正しく適用される
- 一覧画面（W-4）で期限が近い本が視覚的に識別できる
- 詳細画面（W-6）にも同様のビジュアルが表示される

## 調査結果

以下はすでに実装済みであることを確認:
- `Book#deadline_urgency_class` メソッド（model）
- CSSクラス（`.book-card__cover--urgent-low/medium/high`、`.book-card__urgency-badge`）
- W-4 index.html.erb での urgency class 適用と緊急バッジ表示
- book_spec.rb での `deadline_urgency_class` テスト

**未実装**:
- W-6 show.html.erb への書影エリア追加と urgency class/バッジ適用
- show ページに対するリクエストスペック
