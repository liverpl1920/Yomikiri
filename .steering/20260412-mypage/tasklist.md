# タスクリスト: マイページ表示・ニックネーム編集機能 (#27)

## 🚨 タスク完全完了の原則

**このファイルの全タスクが完了するまで作業を継続すること**

---

## フェーズ1: モデル

- [x] User モデルに読書実績メソッドを追加
  - [x] `completed_books_count` メソッドを追加
  - [x] `completed_pages_total` メソッドを追加
  - [x] `consecutive_reading_days` メソッドを追加

## フェーズ2: ルーティング・コントローラー

- [x] `resource :mypage` をルーティングに追加（show/update）
- [x] `MypagesController` を作成（show/update アクション）

## フェーズ3: ビュー・スタイル

- [x] `app/views/mypages/show.html.erb` を作成
  - [x] ユーザー情報セクション（ニックネーム・メール・登録日）
  - [x] ニックネーム編集フォーム（インライン）
  - [x] 読書実績セクション（読了冊数・総ページ数・連続読書日数）
  - [x] 読了履歴リスト（completed_at 降順）
  - [x] アカウント設定リンク（パスワード変更）
  - [x] 「一覧に戻る」ボタン
- [x] `app/assets/stylesheets/mypages.css` を作成（BEM 命名規則）

## フェーズ4: ヘッダー更新

- [x] `app/views/shared/_header.html.erb` の「マイページ」リンクを `mypage_path` に変更

## フェーズ5: テスト

- [x] `spec/requests/mypages_spec.rb` を作成
  - [x] 未ログイン → ログイン画面へリダイレクト（GET）
  - [x] ログイン済み → 200 OK（GET）
  - [x] ユーザー情報の表示確認
  - [x] 有効なニックネームで更新成功（PATCH）
  - [x] 無効なニックネームでエラー表示（PATCH）

## フェーズ6: 品質チェック

- [x] `bundle exec rspec spec/requests/mypages_spec.rb` でテストが全通過することを確認
- [x] `bundle exec rspec` で全テストが通過することを確認
- [x] `bundle exec rubocop` でエラーがないことを確認

---

## 実装後の振り返り

### 実装完了日
2026-04-12

### 計画と実績の差分

**計画と異なった点**:
- 計画通りに実装できた。全タスクを予定通り完了。

### 学んだこと
- `resource :mypage`（単数リソース）を使うことで `GET /mypage` → show、`PATCH /mypage` → update のルート設計が自然に実現できる。
- User モデルにドメインロジック（連続読書日数計算）を集約し、コントローラーを薄く保つことが重要。
- `display_name` ヘルパーメソッドをモデルに持つことで、ビューとコントローラー両方でニックネームのフォールバックを一元管理できる。

### 次回への改善提案
- 連続読書日数の計算は現在 `books.updated_at` を日付集計する簡易実装。将来的には「読書ログ」テーブルを設けてより精度の高い計算に改善できる。
- ニックネーム編集とプロフィール情報を Turbo Frames で部分更新にするとUXが向上する。
