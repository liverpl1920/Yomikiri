# frozen_string_literal: true

class BookMemosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_book
  before_action :set_book_memo, only: [ :destroy ]

  def create
    @book_memo = @book.book_memos.build(book_memo_params)
    if @book_memo.save
      redirect_to @book, notice: "メモを追加しました。"
    else
      @book_memos = @book.book_memos.latest_first
      @new_book_memo = @book_memo
      render "books/show", status: :unprocessable_entity
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
    params.require(:book_memo).permit(:content)
  end
end
