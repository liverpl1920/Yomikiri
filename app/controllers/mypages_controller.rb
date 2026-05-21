# frozen_string_literal: true

class MypagesController < ApplicationController
  DAILY_LOG_WINDOW_DAYS = 7
  STATS_PERIODS = %w[weekly monthly].freeze

  before_action :authenticate_user!
  before_action :set_completed_books, only: %i[show update]
  before_action :set_reading_logs, only: %i[show update]

  def show; end

  def stats
    @period = normalized_period
    @summary = ReadingReportSummaryService.call(user: current_user, period_type: @period)
    @completed_books_count = completed_books_count_in_period
    @average_pages_per_day = average_pages_per_day
    @max_pages_read = @summary[:books].map { |book| book[:pages_read] }.max.to_i
  end

  def update
    if current_user.update(nickname_params)
      redirect_to mypage_path, notice: "ニックネームを更新しました。"
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_completed_books
    @completed_books = current_user.books.completed.order(completed_at: :desc)
  end

  def nickname_params
    params.require(:user).permit(:nickname)
  end

  def set_reading_logs
    end_date = Date.current
    start_date = end_date - (DAILY_LOG_WINDOW_DAYS - 1).days

    logs_by_date = ReadingLog
      .joins(:book)
      .includes(:book)
      .where(books: { user_id: current_user.id }, read_at: start_date..end_date)
      .order(read_at: :desc, created_at: :desc)
      .group_by(&:read_at)

    @daily_reading_logs = (start_date..end_date).to_a.reverse.map do |date|
      [ date, logs_by_date.fetch(date, Array.new) ]
    end
  end

  def normalized_period
    period = params[:period].to_s
    STATS_PERIODS.include?(period) ? period : "weekly"
  end

  def completed_books_count_in_period
    current_user.books.completed.where(completed_at: period_time_range).count
  end

  def average_pages_per_day
    days = (@summary[:start_date]..@summary[:end_date]).count
    return 0 if days.zero?

    (@summary[:total_pages].to_f / days).round(1)
  end

  def period_time_range
    @summary[:start_date].beginning_of_day..@summary[:end_date].end_of_day
  end
end
