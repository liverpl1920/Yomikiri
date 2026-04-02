# frozen_string_literal: true

class BooksController < ApplicationController
  before_action :authenticate_user!

  def index
    @books = current_user.books.for_index_list
  end
end
