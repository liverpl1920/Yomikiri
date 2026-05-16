# frozen_string_literal: true

class MypagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_completed_books, only: %i[show update]
  before_action :set_reading_logs, only: %i[show update]

  def show; end

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
    @reading_logs_by_date = ReadingLog
      .joins(:book)
      .includes(:book)
      .where(books: { user_id: current_user.id })
      .order(read_at: :desc, created_at: :desc)
      .group_by(&:read_at)
  end
end
