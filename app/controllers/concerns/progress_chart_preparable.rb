# frozen_string_literal: true

module ProgressChartPreparable
  extend ActiveSupport::Concern

  private

  def prepare_progress_chart_data
    @progress_chart_max_pages = @book.pages

    unless @book.reading_logs.exists?
      @progress_chart_data = []
      return
    end

    end_date = progress_chart_end_date
    start_date = progress_chart_start_date(end_date)

    logs_by_date = @book.reading_logs
                        .where(read_at: start_date..end_date)
                        .group(:read_at)
                        .sum(:pages_read)

    # 期間前の累積ページ数
    # initial_offset: 登録時のページ数（手動編集分を含む）
    # logs_before: 表示期間より前の読書ログの合計
    initial_offset = @book.current_page - @book.reading_logs.sum(:pages_read)
    logs_before = @book.reading_logs.where("read_at < ?", start_date).sum(:pages_read)
    current_cumulative = initial_offset + logs_before

    @progress_chart_data = (start_date..end_date).map do |date|
      pages_read = logs_by_date.fetch(date, 0)
      current_cumulative += pages_read
      { date: date, pages_read: pages_read, cumulative_pages: current_cumulative }
    end
  end

  def progress_chart_end_date
    return @book.completed_at.to_date if @book.completed? && @book.completed_at.present?

    Date.current
  end

  def progress_chart_start_date(end_date)
    first_log_date = @book.reading_logs.minimum(:read_at)
    start_date = first_log_date || @book.created_at.to_date || end_date

    start_date > end_date ? end_date : start_date
  end
end
