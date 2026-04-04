# frozen_string_literal: true

class BooksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_book, only: [ :show, :destroy, :update_progress ]

  def index
    @books = current_user.books.for_index_list
  end

  def new
    @book = current_user.books.build
  end

  def create
    @book = current_user.books.build(book_params)
    if @book.save
      redirect_to @book, notice: "#{@book.title}を登録しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def update_progress
    new_page = calculate_new_page
    if @book.update(current_page: new_page)
      redirect_to @book, notice: "進捗を更新しました。"
    else
      render :show, status: :unprocessable_entity
    end
  end

  def destroy
    @book.destroy
    redirect_to books_path, notice: "#{@book.title}を削除しました。"
  end

  private

  def set_book
    @book = current_user.books.find_by(id: params[:id])
    render file: Rails.public_path.join("404.html"), status: :not_found, layout: false unless @book
  end

  def calculate_new_page
    if params[:direct_page].present?
      params[:direct_page].to_i
    else
      @book.current_page + params[:pages_read].to_i
    end
  end

  def book_params
    params.require(:book).permit(:title, :author, :total_pages, :target_pages, :current_page, :deadline, :status)
  end
end
