# Issue #9: Book モデルの作成 — 要求定義

## 概要

積読管理アプリ Yomikiri の中核となる `books` テーブルと `Book` モデルを作成する。

## 実装内容

### books テーブル（マイグレーション）

| カラム名 | 型 | 制約 | 備考 |
|----------|-----|------|------|
| user_id | bigint | NOT NULL, FK | 外部キー（users テーブル） |
| title | string | NOT NULL | 書籍タイトル |
| author | string | NULL 許可 | 著者名 |
| total_pages | integer | NOT NULL | 総ページ数 |
| target_pages | integer | NOT NULL | 読了対象ページ数 |
| current_page | integer | NOT NULL, default: 0 | 現在のページ |
| deadline | date | NOT NULL | 読了期限（賞味期限） |
| status | integer | NOT NULL, default: 0 | 読書ステータス（enum） |
| extension_count | integer | NOT NULL, default: 0 | 期限延長回数 |
| completed_at | datetime | NULL 許可 | 読了日時 |

※ 書影は Active Storage で管理するため、books テーブルにカラムは持たない（Issue #22 で設定）

### Book モデル

- **アソシエーション**: `belongs_to :user`
- **enum**: `status { unread: 0, reading: 1, completed: 2 }`
- **バリデーション**:
  - `title`: 必須、255文字以内
  - `total_pages`: 必須、1以上の整数
  - `target_pages`: 必須、1以上、total_pages 以下
  - `current_page`: 必須、0以上、target_pages 以下
  - `deadline`: 必須
  - `status`: 必須

### User モデル

- `has_many :books, dependent: :destroy` を追加（Issue #4 実装済みの場合は確認のみ）

## 完了条件

- マイグレーションが正常に完了する
- バリデーションが正しく動作する（必須項目の欠如時にエラー）
- enum でステータスの取得・更新ができる
- RSpec モデルスペックがパスする
