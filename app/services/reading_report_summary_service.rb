# frozen_string_literal: true

class ReadingReportSummaryService
  PERIOD_TYPES = %i[weekly monthly custom].freeze
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

    {
      period_type:,
      period_label:,
      start_date: period_range.begin,
      end_date: period_range.end,
      books:,
      total_pages:,
      daily_pages:,
      reading_log_details:
    }
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
    when :custom then "カスタム期間"
    end
  end

  def period_range
    @period_range ||= begin
      case period_type
      when :weekly
        (reference_date - 6.days)..reference_date
      when :monthly
        reference_date.beginning_of_month..reference_date.end_of_month
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
end
