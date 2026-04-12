# frozen_string_literal: true

class MypagesController < ApplicationController
  before_action :authenticate_user!

  def show
    @completed_books = current_user.books.completed.order(completed_at: :desc)
  end

  def update
    if current_user.update(nickname_params)
      redirect_to mypage_path, notice: "ニックネームを更新しました。"
    else
      @completed_books = current_user.books.completed.order(completed_at: :desc)
      render :show, status: :unprocessable_entity
    end
  end

  private

  def nickname_params
    params.require(:user).permit(:nickname)
  end
end
