class ReadingReportSummaryService
  PERIOD_TYPES = %i[weekly monthly].freeze

  def self.call(user:, period_type:, reference_date: Date.current)
    new(user:, period_type:, reference_date:).call
  end

  def initialize(user:, period_type:, reference_date: Date.current)
    @user = user
    @period_type = period_type.to_sym
    @reference_date = reference_date
  end

  def call
    validate_period_type!

    {
      period_type:,
      period_label:,
      start_date: period_range.begin,
      end_date: period_range.end,
      books:,
      total_pages:
    }
  end

  private

  attr_reader :user, :period_type, :reference_date

  def validate_period_type!
    return if PERIOD_TYPES.include?(period_type)

    raise ArgumentError, "Unsupported period type: #{period_type}"
  end

  def period_label
    period_type == :weekly ? "週次" : "月次"
  end

  def period_range
    @period_range ||= begin
      case period_type
      when :weekly
        (reference_date - 6.days)..reference_date
      when :monthly
        reference_date.beginning_of_month..reference_date.end_of_month
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
end
