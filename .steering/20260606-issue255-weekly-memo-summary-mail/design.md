# Issue #255 設計

## 変更対象ファイル

### 1. `app/services/reading_report_summary_service.rb`
- `call` メソッドの返却ハッシュに `memo_details:` を追加
- `memo_details` メソッドを新規追加
  - `BookMemo.joins(:book).where(books: { user_id: user.id }, created_at: period_range_for_memos)` で取得
  - 返却形式: `[{ book_title:, page_number:, content:, created_at: }]` の配列

### 2. `app/views/reading_report_mailer/weekly_report.text.erb`
- メモセクションを追加
  - `@summary[:memo_details]` が空なら「- 該当なし」
  - 各メモを「- [書籍名] (p.ページ番号): メモ内容」形式で表示

### 3. `.github/workflows/reading-report-mail.yml`
- cron を `0 23 * * 5`（金曜23:00 UTC = 土曜08:00 JST）に変更
- 既存の毎日実行（`5 15 * * *`）からの変更

## メモの期間フィルタリング設計

`BookMemo` には `read_at` がなく `created_at` を使用する。
週次期間（`reference_date - 6.days〜reference_date`）に対し、`created_at` の日付部分で比較するため、
日付範囲を `created_at >= start_date.beginning_of_day AND created_at < (end_date + 1).beginning_of_day` と設定する。

```ruby
def memo_details
  start_dt = period_range.begin.beginning_of_day
  end_dt   = (period_range.end + 1.day).beginning_of_day
  BookMemo
    .joins(:book)
    .where(books: { user_id: user.id }, created_at: start_dt...end_dt)
    .includes(:book)
    .order(created_at: :desc)
    .map do |memo|
      {
        book_title:  memo.book.title,
        page_number: memo.page_number,
        content:     memo.content,
        created_at:  memo.created_at.to_date
      }
    end
end
```

## テスト変更

### `spec/services/reading_report_summary_service_spec.rb`
- `memo_details` のキーが存在することを確認するテストを追加
- 週次期間内のメモのみが含まれることを確認するテストを追加

### `spec/mailers/reading_report_mailer_spec.rb`
- `weekly_report` のテストにメモ情報の本文確認を追加
