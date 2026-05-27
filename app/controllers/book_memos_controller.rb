# frozen_string_literal: true

class BookMemosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_book
  before_action :set_book_memo, only: [ :destroy, :edit, :update ]

  def create
    @book_memo = @book.book_memos.build(book_memo_params)
    if @book_memo.save
      redirect_to @book, notice: "メモを追加しました。"
    else
      @book_memos = @book.book_memos.latest_first
      @new_book_memo = @book_memo
      prepare_progress_chart_data
      render "books/show", status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @book_memo.update(book_memo_params)
      redirect_to @book, notice: "メモを更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @book_memo.destroy
    redirect_to @book, notice: "メモを削除しました。", status: :see_other
  end

  private

  def set_book
    @book = current_user.books.find_by(id: params[:book_id])
    render file: Rails.public_path.join("404.html"), status: :not_found, layout: false unless @book
  end

  def set_book_memo
    @book_memo = @book.book_memos.find_by(id: params[:id])
    render file: Rails.public_path.join("404.html"), status: :not_found, layout: false unless @book_memo
  end

  def book_memo_params
    params.require(:book_memo).permit(:content, :page_number)
  end

  def prepare_progress_chart_data
    unless @book.reading_logs.exists?
      @progress_chart_data = []
      @progress_chart_max_pages = 0
      return
    end

    end_date = progress_chart_end_date
    start_date = progress_chart_start_date(end_date)

    logs_by_date = @book.reading_logs
                        .where(read_at: start_date..end_date)
                        .group(:read_at)
                        .sum(:pages_read)

    @progress_chart_data = (start_date..end_date).map do |date|
      { date: date, pages_read: logs_by_date.fetch(date, 0) }
    end
    @progress_chart_max_pages = @progress_chart_data.map { |row| row[:pages_read] }.max.to_i
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
