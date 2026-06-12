# frozen_string_literal: true

class ReadingReportSummaryService
  PERIOD_TYPES = %i[weekly monthly yearly custom].freeze
  MAX_CUSTOM_PERIOD_DAYS = 366

  def self.call(user:, period_type:, reference_date: Date.current, start_date: nil, end_date: nil)
    new(user:, period_type:, reference_date:, start_date:, end_date:).call
  end

  def initialize(user:, period_type:, reference_date: Date.current, start_date: nil, end_date: nil)
    @user = user
    @period_type = period_type.to_sym
    @reference_date = reference_date
    @custom_start_date = start_date
    @custom_end_date = end_date
  end

  def call
    validate_period_type!

    data = {
      period_type:,
      period_label:,
      start_date: period_range.begin,
      end_date: period_range.end,
      books:,
      genres:,
      total_pages:,
      daily_pages:,
      reading_log_details:,
      memo_details:
    }

    if period_type == :monthly
      data.merge!(monthly_report_details)
    elsif period_type == :yearly
      data.merge!(yearly_report_details)
    end

    data
  end

  private

  attr_reader :user, :period_type, :reference_date, :custom_start_date, :custom_end_date

  def validate_period_type!
    return if PERIOD_TYPES.include?(period_type)

    raise ArgumentError, "Unsupported period type: #{period_type}"
  end

  def period_label
    case period_type
    when :weekly then "週次"
    when :monthly then "月次"
    when :yearly then "年次"
    when :custom then "カスタム期間"
    end
  end

  def period_range
    @period_range ||= begin
      case period_type
      when :weekly
        (reference_date - 6.days)..reference_date
      when :monthly
        (reference_date - 1.month).beginning_of_month..(reference_date - 1.month).end_of_month
      when :yearly
        (reference_date - 1.year).beginning_of_year..(reference_date - 1.year).end_of_year
      when :custom
        start = custom_start_date || reference_date
        finish = custom_end_date || reference_date
        start, finish = finish, start if start > finish
        finish = start + MAX_CUSTOM_PERIOD_DAYS - 1 if (finish - start).to_i >= MAX_CUSTOM_PERIOD_DAYS
        start..finish
      end
    end
  end

  def scoped_logs
    @scoped_logs ||= ReadingLog
      .joins(:book)
      .where(books: { user_id: user.id }, read_at: period_range)
  end

  def books
    grouped = scoped_logs.group("books.title").sum(:pages_read)
    grouped
      .map { |title, pages_read| { title: title, pages_read: pages_read } }
      .sort_by { |row| [ -row[:pages_read], row[:title] ] }
  end

  def total_pages
    scoped_logs.sum(:pages_read)
  end

  def daily_pages
    grouped = scoped_logs.group(:read_at).sum(:pages_read)
    (period_range.begin..period_range.end).each_with_object({}) do |date, hash|
      hash[date] = grouped.fetch(date, 0)
    end
  end

  def reading_log_details
    scoped_logs
      .includes(:book)
      .order(read_at: :desc, created_at: :desc)
      .map do |log|
        {
          read_at: log.read_at,
          book_title: log.book.title,
          start_page: log.start_page,
          end_page: log.end_page,
          pages_read: log.pages_read
        }
      end
  end

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

  def genres
    grouped = scoped_logs
      .group("CASE WHEN books.genre IS NULL OR books.genre = '' THEN '未分類' ELSE books.genre END")
      .sum(:pages_read)

    total = total_pages
    return [] if total.zero?

    grouped.map do |genre_name, pages|
      ratio = ((pages.to_f / total) * 100).round(1)
      { name: genre_name, pages_read: pages, ratio: ratio }
    end.sort_by { |g| [ -g[:pages_read], g[:name] ] }
  end

  def monthly_report_details
    completed_b = user.books.where(completed_at: period_range).order(completed_at: :asc)
    completed_b_ids = completed_b.pluck(:id)

    progressing_b_grouped = scoped_logs.where.not(book_id: completed_b_ids).group("books.title").sum(:pages_read)
    progressing_books = progressing_b_grouped.map { |title, pages| { title:, pages_read: pages } }
                                              .sort_by { |b| [ -b[:pages_read], b[:title] ] }

    active_book_ids = (scoped_logs.pluck(:book_id) + completed_b_ids).uniq
    extensions = user.books.where(id: active_book_ids).sum(:extension_count)

    completed_in_deadline = user.books.where(completed_at: period_range)
                                       .where("completed_at::date <= deadline").count

    overdue_count = user.books.where(status: [ :unread, :reading ])
                              .where("deadline < ?", period_range.end).count

    next_month_range = reference_date.beginning_of_month..reference_date.end_of_month
    next_month_urgent = user.books.where(status: [ :unread, :reading ], deadline: next_month_range)
                                  .order(deadline: :asc)
                                  .map do |book|
                                    { title: book.title, progress: book.progress_percentage, daily_quota: book.daily_quota }
                                  end

    {
      reading_days_count: scoped_logs.select(:read_at).distinct.count,
      completed_books: completed_b.map { |b| { title: b.title, completed_at: b.completed_at.to_date } },
      progressing_books: progressing_books,
      tsundoku_balance: {
        registered: user.books.where(created_at: period_range.begin.beginning_of_day...period_range.end.end_of_day).count,
        completed: completed_b.count
      },
      deadline_status: {
        completed_in_deadline: completed_in_deadline,
        extensions: extensions,
        overdue_count: overdue_count
      },
      next_month_urgent_books: next_month_urgent,
      random_memos: memo_details.sample(2)
    }
  end

  def yearly_report_details
    completed_b = user.books.where(completed_at: period_range)
    completed_b_ids = completed_b.pluck(:id)

    monthly_pages = scoped_logs.group("EXTRACT(MONTH FROM read_at)").sum(:pages_read)
    peak_m = monthly_pages.max_by { |_, v| v }&.first&.to_i

    # 電光石火アワード: 登録から最も短い期間で読了した本
    completed_array = completed_b.to_a
    lightning = completed_array.min_by { |b| (b.completed_at.to_date - b.created_at.to_date).to_i }
    lightning_award = if lightning
      { title: lightning.title, days: (lightning.completed_at.to_date - lightning.created_at.to_date).to_i }
    end

    # 最も向き合った本: 年間読書ページ数が最大の本
    grouped_pages = scoped_logs.group(:book_id).sum(:pages_read)
    most_faced_id, max_pages = grouped_pages.max_by { |_, pages| pages }
    most_faced = if most_faced_id
      faced_book = user.books.find_by(id: most_faced_id)
      { title: faced_book&.title, pages_read: max_pages }
    end

    # 言い訳アワード: 最も期限延長した本
    active_book_ids = (scoped_logs.pluck(:book_id) + completed_b_ids).uniq
    excuse_book = user.books.where(id: active_book_ids).where("extension_count > 0").order(extension_count: :desc).first
    excuse_award = if excuse_book
      { title: excuse_book.title, extension_count: excuse_book.extension_count }
    end

    # 特にメモが多かった本と抜粋
    memos_in_year = BookMemo.joins(:book)
                            .where(books: { user_id: user.id }, created_at: period_range.begin.beginning_of_day..period_range.end.end_of_day)
                            .includes(:book)
    grouped_memos = memos_in_year.group(:book_id).count
    most_memo_book_id, count = grouped_memos.max_by { |_, c| c }
    most_memo_info = if most_memo_book_id
      book = user.books.find(most_memo_book_id)
      excerpt = book.book_memos.where(created_at: period_range.begin.beginning_of_day..period_range.end.end_of_day).order(created_at: :desc).first
      { title: book.title, total_memos: count, excerpt_content: excerpt&.content }
    end

    current_books = user.books.where(status: [ :unread, :reading ])
    total_rem = current_books.sum("pages - current_page")

    new_year_proposal = user.books.where(status: [ :unread, :reading ]).where.not(deadline: nil).order(deadline: :asc).first&.title

    {
      yearly_completed_books_count: completed_b.count,
      yearly_reading_days_count: scoped_logs.select(:read_at).distinct.count,
      peak_month: peak_m,
      lightning_award_book: lightning_award,
      most_faced_book: most_faced,
      excuse_award_book: excuse_award,
      most_memo_book_and_excerpt: most_memo_info,
      tsundoku_current_state: { count: current_books.count, total_pages: total_rem },
      new_year_proposal_book: new_year_proposal
    }
  end
end
