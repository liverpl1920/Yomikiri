# frozen_string_literal: true

class BooksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_book, only: [ :show, :destroy, :update_progress, :complete, :change_deadline ]

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
    if new_page.nil?
      @book.errors.add(:base, "ページ数が無効です")
      render :show, status: :unprocessable_entity
    elsif @book.update(current_page: new_page)
      redirect_to @book, notice: "進捗を更新しました。"
    else
      render :show, status: :unprocessable_entity
    end
  end

  def change_deadline
    new_deadline = Date.parse(params[:deadline].to_s)
    if @book.extend_deadline!(new_deadline)
      redirect_to @book, notice: "読了期限を延長しました。"
    else
      render :show, status: :unprocessable_entity
    end
  rescue Date::Error
    @book.errors.add(:deadline, :invalid)
    render :show, status: :unprocessable_entity
  end

  def complete
    completed_at = @book.completed_at || Time.current
    if @book.update(status: :completed, current_page: @book.target_pages, completed_at: completed_at)
      flash[:completed_book] = @book.title
      redirect_to @book
    else
      render :show, status: :unprocessable_entity
    end
  end

  def destroy
    @book.destroy
    redirect_to books_path, notice: "#{@book.title}を削除しました。", status: :see_other
  end

  private

  def set_book
    @book = current_user.books.find_by(id: params[:id])
    render file: Rails.public_path.join("404.html"), status: :not_found, layout: false unless @book
  end

  def calculate_new_page
    if params[:direct_page].present?
      direct_page = Integer(params[:direct_page], exception: false)
      return nil if direct_page.nil? || direct_page.negative? || direct_page > @book.target_pages

      direct_page
    else
      pages_read = Integer(params[:pages_read], exception: false)
      return nil if pages_read.nil? || pages_read <= 0

      @book.current_page + pages_read
    end
  end

  def book_params
    params.require(:book).permit(:title, :author, :total_pages, :target_pages, :current_page, :deadline, :status, :cover_image_url)
  end
end
