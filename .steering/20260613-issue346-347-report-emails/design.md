# Design: 月次・年次レポートメール送信機能の設計

## 1. データベースアクセスと集計ロジック

### 1.1 期間計算の変更
`ReadingReportSummaryService` の `period_range` 計算を基準日 `reference_date`（送信実行日。例えば翌月1日や翌年1月1日）から見た前月・前年を対象とするよう変更します。

```ruby
      when :monthly
        # 基準日の前月1日〜前月末日
        (reference_date - 1.month).beginning_of_month..(reference_date - 1.month).end_of_month
      when :yearly
        # 基準日の前年1月1日〜前年12月31日
        (reference_date - 1.year).beginning_of_year..(reference_date - 1.year).end_of_year
```

これにより、既存の `ReadingReportSummaryService` 内の `scoped_logs` や `memo_details` の期間フィルタはそのまま流用できます。

---

### 1.2 月次レポート用の集計項目（追加）

`ReadingReportSummaryService` の `monthly` モードにおいて、以下の追加データを返すメソッド・ハッシュ項目を実装します。

- `reading_days_count`:
  ```ruby
  scoped_logs.select(:read_at).distinct.count
  ```
- `completed_books`:
  期間内に読了した本。
  ```ruby
  user.books.where(completed_at: period_range).order(completed_at: :asc).map do |book|
    { title: book.title, completed_at: book.completed_at.to_date }
  end
  ```
- `progressing_books`:
  期間内に読み進めたが、期間内には読了していない（または未読了）の本。
  ```ruby
  completed_book_ids = user.books.where(completed_at: period_range).pluck(:id)
  grouped_logs = scoped_logs.where.not(book_id: completed_book_ids).group("books.title").sum(:pages_read)
  grouped_logs.map { |title, pages| { title: title, pages_read: pages } }
              .sort_by { |b| -b[:pages_read] }
  ```
- `tsundoku_balance`:
  積読の増減（新規登録した冊数 vs 今月読了した冊数）。
  ```ruby
  registered = user.books.where(created_at: period_range.begin.beginning_of_day...period_range.end.end_of_day).count
  completed = user.books.where(completed_at: period_range).count
  { registered: registered, completed: completed }
  ```
- `deadline_status`:
  賞味期限の達成状況。
  - 期限内に読了できた本: 期間内読了本のうち、`completed_at.to_date <= deadline` である件数。
  - 期限を延長した回数: 期間中にアクティブだった（期間中に `reading_logs` がある、または期間中に `completed_at` がある）本の中での `extension_count` の総和。
  - 期限切れになっている本: 期間の最終日時点（＝前月末日）で未読了かつ期限切れの本の件数。
  ```ruby
  active_book_ids = (scoped_logs.pluck(:book_id) + user.books.where(completed_at: period_range).pluck(:id)).uniq
  extensions = user.books.where(id: active_book_ids).sum(:extension_count)

  completed_in_deadline = user.books.where(completed_at: period_range)
                                     .where("completed_at::date <= deadline").count

  overdue_count = user.books.where(status: [:unread, :reading])
                            .where("deadline < ?", period_range.end).count
  { completed_in_deadline: completed_in_deadline, extensions: extensions, overdue_count: overdue_count }
  ```
- `next_month_urgent_books`:
  基準日（翌月1日）から見て「翌月（＝今月）」に期限を迎える未読了の本のリスト。
  ※ reference_date = 7月1日の場合、7月中に期限を迎える本。
  ```ruby
  next_month_range = reference_date.beginning_of_month..reference_date.end_of_month
  user.books.where(status: [:unread, :reading], deadline: next_month_range)
            .order(deadline: :asc)
            .map do |book|
              { title: book.title, progress: book.progress_percentage, daily_quota: book.daily_quota }
            end
  ```
- `random_memos`:
  今月のメモからランダムに最大2件を抜粋。
  ```ruby
  memos = memo_details # 既に取得されている配列
  memos.sample(2)
  ```

---

### 1.3 年次レポート用集計サービス (`YearlyReportSummaryService` もしくは `ReadingReportSummaryService` の `:yearly` 対応)

`ReadingReportSummaryService` を拡張し、`:yearly` にも対応させます。
`PERIOD_TYPES` に `:yearly` を追加し、`yearly` 時の集計ロジックを以下のように実装します。

- `yearly_reading_days_count`: `scoped_logs.select(:read_at).distinct.count`
- `yearly_completed_books_count`: `user.books.where(completed_at: period_range).count`
- `peak_month`:
  年間で最も読書ページ数が多かった月。
  ```ruby
  monthly_pages = scoped_logs.group("EXTRACT(MONTH FROM read_at)").sum(:pages_read)
  # { 10.0 => 350, 11.0 => 200 } のようなハッシュから最大値を求める
  peak_m = monthly_pages.max_by { |_, v| v }&.first&.to_i
  peak_m # nil の場合は「該当なし」
  ```
- `lightning_award_book`:
  「電光石火アワード」（登録から最も短い期間で読了した本）。
  ```ruby
  user.books.where(completed_at: period_range)
            .select("books.*, (completed_at::date - created_at::date) as duration")
            .order("duration ASC, completed_at ASC")
            .first
  # 表示用: { title: book.title, days: (book.completed_at.to_date - book.created_at.to_date).to_i }
  ```
- `most_faced_book`:
  「最も向き合った本」（期間中の読書ページ数が最大の本）。
  ```ruby
  grouped = scoped_logs.group(:book_id).sum(:pages_read)
  most_faced_id = grouped.max_by { |_, pages| pages }&.first
  most_faced_book = user.books.find_by(id: most_faced_id) if most_faced_id
  # 表示用: { title: most_faced_book.title, pages_read: grouped[most_faced_id] }
  ```
- `excuse_award_book`:
  「言い訳アワード」（最も期限延長した本）。
  期間中にアクティブだった本の中で `extension_count` が最大の本。
  ```ruby
  active_book_ids = (scoped_logs.pluck(:book_id) + user.books.where(completed_at: period_range).pluck(:id)).uniq
  excuse_book = user.books.where(id: active_book_ids).where("extension_count > 0").order(extension_count: :desc).first
  # 表示用: { title: excuse_book.title, extension_count: excuse_book.extension_count }
  ```
- `most_memo_book_and_excerpt`:
  「特にメモが多かった本と、そのメモの抜粋」。
  ```ruby
  memos_in_year = BookMemo.joins(:book).where(books: { user_id: user.id }, created_at: period_range.begin.beginning_of_day..period_range.end.end_of_day)
  grouped_memos = memos_in_year.group(:book_id).count
  most_memo_book_id = grouped_memos.max_by { |_, count| count }&.first
  if most_memo_book_id
    book = user.books.find(most_memo_book_id)
    excerpt = book.book_memos.where(created_at: period_range.begin.beginning_of_day..period_range.end.end_of_day).order(created_at: :desc).first
    { title: book.title, total_memos: grouped_memos[most_memo_book_id], excerpt_content: excerpt&.content }
  else
    nil
  end
  ```
- `tsundoku_current_state`:
  新年に向けた「積読の現在地」（基準日時点で未読・読書中の本の総数・総ページ数）。
  ```ruby
  current_books = user.books.where(status: [:unread, :reading])
  { count: current_books.count, total_pages: current_books.sum("pages - current_page") }
  ```
- `new_year_proposal_book`:
  新年最初の目標提案（基準日時点で未読・読書中の本の中で、期限が最も近い本）。
  ```ruby
  user.books.where(status: [:unread, :reading]).order(deadline: :asc).first
  ```

---

## 2. メール送信の追加
`ReadingReportMailer` に `yearly_report` メソッドを追加します。
また、月次レポートのビューテンプレート (`app/views/reading_report_mailer/monthly_report.text.erb`) を詳細要件に合わせて書き直し、年次レポートのビューテンプレート (`app/views/reading_report_mailer/yearly_report.text.erb`) を新規作成します。

---

## 3. ジョブとRakeタスクの更新
- `ReadingReportDispatchJob` にて `:yearly` を許容するように定数 `PERIOD_TYPES` を更新します。
- `mail_for` メソッドにて `period_type == "yearly"` の場合に `ReadingReportMailer.yearly_report` を呼び出すように分岐を追加します。
- `lib/tasks/reading_reports.rake` の `dispatch` タスクにおいて、起動判定ロジックを以下のように更新します。
  - `run_monthly = reference_date.day == 1`
  - `run_yearly = reference_date.month == 1 && reference_date.day == 1`
  - `yearly` のジョブ起動を追加します。
