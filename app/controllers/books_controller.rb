class BooksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_book, only: [ :show ]

  def index
    @books = current_user.books.order(deadline: :asc)
  end

  def new
    @book = current_user.books.new
  end

  def create
    @book = current_user.books.build(book_params)
    if @book.save
      redirect_to @book, notice: "書籍を登録しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  private

  def set_book
    @book = current_user.books.find(params[:id])
  end

  def book_params
    params.require(:book).permit(
      :title,
      :author,
      :total_pages,
      :target_pages,
      :current_page,
      :deadline
    )
  end
end
