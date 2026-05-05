# frozen_string_literal: true

require "net/http"

class BooksController < ApplicationController
  GoogleBooksApiError = Class.new(StandardError)
  ALLOWED_COVER_HOSTS = %w[books.google.com].freeze
  ALLOWED_REDIRECT_HOSTS = %w[books.google.com lh3.googleusercontent.com].freeze
  MAX_REDIRECTS = 3

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
  rescue GoogleBooksApiError => e
    render json: { books: [], error: e.message }
  rescue StandardError
    render json: { books: [], error: "検索中にエラーが発生しました" }
  end

  def cover_proxy
    url = params[:url].to_s
    uri = URI.parse(url)
    return head :forbidden unless ALLOWED_COVER_HOSTS.include?(uri.host)

    result = fetch_with_redirects(uri)
    case result
    when :forbidden
      head :forbidden
    when Net::HTTPResponse
      content_type = result["content-type"] || "image/jpeg"
      send_data result.body, type: content_type, disposition: "inline"
    else
      head :not_found
    end
  rescue URI::InvalidURIError
    head :bad_request
  rescue Net::OpenTimeout, Net::ReadTimeout
    head :not_found
  rescue StandardError
    head :not_found
  end

  private

  def fetch_with_redirects(uri, redirect_count = 0)
    return nil if redirect_count > MAX_REDIRECTS

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https",
                                open_timeout: 5, read_timeout: 5) do |http|
      http.get(uri.request_uri)
    end

    if response.is_a?(Net::HTTPRedirection)
      location = response["location"]
      redirect_uri = URI.parse(location)
      return :forbidden unless ALLOWED_REDIRECT_HOSTS.include?(redirect_uri.host)

      fetch_with_redirects(redirect_uri, redirect_count + 1)
    elsif response.is_a?(Net::HTTPSuccess)
      response
    end
  end

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
    total_pages = extract_pages_from_onix(book["onix"])
    openbd_url = book.dig("summary", "cover").to_s.presence || ""
    cover_image_url = resolve_cover_url(openbd_url, isbn, nil, isbn_search: true)
    [ {
      title: book.dig("summary", "title").to_s,
      author: book.dig("summary", "author").to_s,
      total_pages: total_pages,
      cover_image_url: cover_image_url
    } ]
  end

  def search_by_title(title)
    uri = URI("https://www.googleapis.com/books/v1/volumes")
    uri.query = URI.encode_www_form(q: "intitle:#{title}", langRestrict: "ja", maxResults: 5)
    data = fetch_title_json(uri.to_s)
    items = data&.dig("items") || []

    items.map do |item|
      info = item["volumeInfo"] || {}
      isbn = extract_isbn_from_identifiers(info["industryIdentifiers"])
      openbd_url = lookup_openbd_cover_url(isbn)
      google_thumbnail = info.dig("imageLinks", "thumbnail").to_s.sub(/\Ahttp:/, "https:")
      {
        title: info["title"].to_s,
        author: Array(info["authors"]).join(", "),
        total_pages: info["pageCount"],
        cover_image_url: resolve_cover_url(openbd_url, isbn, google_thumbnail)
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

  def fetch_title_json(url)
    uri = URI(url)
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https",
                                                   open_timeout: 5, read_timeout: 5) do |http|
      http.get(uri.request_uri)
    end
    case response
    when Net::HTTPSuccess
      JSON.parse(response.body)
    when Net::HTTPTooManyRequests
      raise GoogleBooksApiError, "検索リクエストが制限されています。しばらく時間をおいてから再度お試しください。"
    when Net::HTTPServerError
      raise GoogleBooksApiError, "書影の取得中にサーバーエラーが発生しました。しばらく時間をおいてから再度お試しください。"
    else
      nil
    end
  rescue GoogleBooksApiError
    raise
  rescue Net::OpenTimeout, Net::ReadTimeout
    raise GoogleBooksApiError, "検索がタイムアウトしました。接続を確認して再度お試しください。"
  rescue StandardError
    raise GoogleBooksApiError, "検索中に予期しないエラーが発生しました。しばらく時間をおいてから再度お試しください。"
  end

  def extract_pages_from_onix(onix)
    return nil if onix.blank?

    extents = Array(onix.dig("DescriptiveDetail", "Extent"))
    page_extent = extents.find { |e| e["ExtentType"] == "11" }
    page_extent&.dig("ExtentValue")&.to_i
  end

  def lookup_openbd_cover_url(isbn)
    return "" if isbn.blank?

    data = fetch_json("https://api.openbd.jp/v1/get?isbn=#{isbn}")
    return "" if data.nil? || data.first.nil?

    data.first.dig("summary", "cover").to_s.presence || ""
  end

  def lookup_rakuten_cover_url(isbn)
    return "" if isbn.blank?

    app_id = ENV["RAKUTEN_APPLICATION_ID"].to_s
    return "" if app_id.blank?

    uri = URI("https://app.rakuten.co.jp/services/api/BooksBook/Search/20170404")
    uri.query = URI.encode_www_form(isbn: isbn, applicationId: app_id, format: "json")
    data = fetch_json(uri.to_s)
    item = data&.dig("Items", 0, "Item")
    return "" if item.nil?

    item["largeImageUrl"].presence || item["mediumImageUrl"].presence || ""
  end

  def lookup_google_books_cover_url(isbn)
    return "" if isbn.blank?

    uri = URI("https://www.googleapis.com/books/v1/volumes")
    uri.query = URI.encode_www_form(q: "isbn:#{isbn}", maxResults: 1)
    data = fetch_json(uri.to_s)
    thumbnail = data&.dig("items", 0, "volumeInfo", "imageLinks", "thumbnail").to_s
    thumbnail.present? ? thumbnail.sub(/\Ahttp:/, "https:") : ""
  end

  def resolve_cover_url(openbd_url, isbn, google_thumbnail, isbn_search: false)
    return openbd_url if openbd_url.present?

    rakuten_url = lookup_rakuten_cover_url(isbn)
    return rakuten_url if rakuten_url.present?

    return google_thumbnail.to_s.presence || "" unless isbn_search

    google_thumbnail.presence || lookup_google_books_cover_url(isbn)
  end

  def extract_isbn_from_identifiers(identifiers)
    return nil if identifiers.blank?

    isbn13 = identifiers.find { |id| id["type"] == "ISBN_13" }
    isbn13&.dig("identifier")&.gsub(/[^0-9]/, "")
  end
end
