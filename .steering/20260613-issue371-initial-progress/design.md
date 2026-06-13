# 設計書 (Issue #371)

## 実装方針
`Book` モデルの `after_create` コールバックを新しく定義し、条件を満たした場合に `ReadingLog` のレコードを作成する。

### 1. `Book` モデルの修正 (`app/models/book.rb`)
- 新しいコールバックの登録：
  ```ruby
  after_create :create_initial_reading_log, if: :should_record_initial_reading_log?
  ```
- コールバック条件判定メソッドの定義：
  ```ruby
  def should_record_initial_reading_log?
    current_page.to_i > 0 && !past_reading_checked?
  end
  ```
- ログ作成メソッドの定義：
  ```ruby
  def create_initial_reading_log
    reading_logs.create!(
      pages_read: current_page,
      read_at: Date.current,
      start_page: 1,
      end_page: current_page
    )
  end
  ```

### 2. テストの設計
- **モデルテスト (`spec/models/book_spec.rb`)**
  - `is_past_reading` が `"false"` もしくは `nil` で、`current_page` が `1` 以上で新規保存したとき、`ReadingLog` が `pages_read: current_page`, `read_at: Date.current`, `start_page: 1`, `end_page: current_page` で作成されることを検証。
  - `current_page` が `0` の場合、`ReadingLog` が作成されないことを検証。
  - `is_past_reading` が `"true"` の場合、この `create_initial_reading_log` コールバックによって重複して作成されないことを検証。
- **リクエストテスト (`spec/requests/books_spec.rb`)**
  - `POST /books` にて、`current_page` に `80` を渡した際、`ReadingLog` が同時に1つ作成され、その内容が正しいことを検証。
