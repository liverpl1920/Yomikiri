# frozen_string_literal: true

require "net/http"

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

  def search
    query = params[:q].to_s.strip
    return render json: { books: [] } if query.blank?

    books = isbn_query?(query) ? search_by_isbn(sanitize_isbn(query)) : search_by_title(query)
    render json: { books: }
  rescue StandardError
    render json: { books: [], error: "検索中にエラーが発生しました" }
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

  def isbn_query?(query)
    sanitize_isbn(query).match?(/\A(?:\d{13}|\d{9}[\dX])\z/)
  end

  def sanitize_isbn(query)
    query.upcase.gsub(/[^0-9X]/, "")
  end

  def search_by_isbn(isbn)
    data = fetch_json("https://api.openbd.jp/v1/get?isbn=#{isbn}")
    return [] if data.nil? || data.first.nil?

    book = data.first
    summary_isbn = book.dig("summary", "isbn").to_s.gsub(/[^0-9]/, "")
    cover_isbn = summary_isbn.match?(/\A\d{13}\z/) ? summary_isbn : ""
    total_pages = extract_pages_from_onix(book["onix"])
    [ {
      title: book.dig("summary", "title").to_s,
      author: book.dig("summary", "author").to_s,
      total_pages: total_pages,
      cover_image_url: cover_isbn.present? ? "https://cover.openbd.jp/#{cover_isbn}.jpg" : ""
    } ]
  end

  def search_by_title(title)
    uri = URI("https://www.googleapis.com/books/v1/volumes")
    uri.query = URI.encode_www_form(q: "intitle:#{title}", langRestrict: "ja", maxResults: 5)
    data = fetch_json(uri.to_s)
    items = data&.dig("items") || []

    items.map do |item|
      info = item["volumeInfo"]
      isbn = extract_isbn_from_identifiers(info["industryIdentifiers"])
      {
        title: info["title"].to_s,
        author: Array(info["authors"]).join(", "),
        total_pages: info["pageCount"],
        cover_image_url: isbn ? "https://cover.openbd.jp/#{isbn}.jpg" : ""
      }
    end
  end

  def fetch_json(url)
    uri = URI(url)
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https",
                                                   open_timeout: 5, read_timeout: 5) do |http|
      http.get(uri.request_uri)
    end
    return nil unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)
  rescue StandardError
    nil
  end

  def extract_pages_from_onix(onix)
    return nil if onix.blank?

    extents = Array(onix.dig("DescriptiveDetail", "Extent"))
    page_extent = extents.find { |e| e["ExtentType"] == "11" }
    page_extent&.dig("ExtentValue")&.to_i
  end

  def extract_isbn_from_identifiers(identifiers)
    return nil if identifiers.blank?

    isbn13 = identifiers.find { |id| id["type"] == "ISBN_13" }
    isbn13&.dig("identifier")&.gsub(/[^0-9]/, "")
  end
end
