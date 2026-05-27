# frozen_string_literal: true

require "net/http"

class BooksController < ApplicationController
  GoogleBooksApiError = Class.new(StandardError)
  ALLOWED_COVER_HOSTS = %w[books.google.com].freeze
  ALLOWED_REDIRECT_HOSTS = %w[books.google.com lh3.googleusercontent.com].freeze
  MAX_REDIRECTS = 3

  before_action :authenticate_user!
  before_action :set_book, only: [ :show, :edit, :update, :destroy, :update_progress, :update_memo, :complete, :change_deadline, :update_review ]

  def index
    @search_params = normalized_index_search_params
    @search_active = @search_params.values.any?(&:present?)
    @books = current_user.books.with_attached_cover_image.filtered_for_index(@search_params)
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
    @book_memos = @book.book_memos.latest_first
    @new_book_memo = @book.book_memos.build
  end

  def edit
  end

  def update
    if @book.update(edit_book_params)
      redirect_to @book, notice: "#{@book.title}の情報を更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def update_progress
    new_page = calculate_new_page
    if new_page.nil?
      @book.errors.add(:base, "ページ数が無効です")
      prepare_show_vars
      render :show, status: :unprocessable_entity
    elsif persist_progress_with_log(new_page)
      redirect_to @book, notice: "進捗を更新しました。"
    else
      prepare_show_vars
      render :show, status: :unprocessable_entity
    end
  end

  def update_memo
    if @book.update(memo_params.merge(memo_updated_at: Time.current))
      flash[:memo_saved] = true
      redirect_to @book, notice: "コメント・メモを更新しました。"
    else
      prepare_show_vars
      render :show, status: :unprocessable_entity
    end
  end

  def change_deadline
    new_deadline = Date.parse(params[:deadline].to_s)
    if @book.extend_deadline!(new_deadline)
      redirect_to @book, notice: "読了期限を延長しました。", status: :see_other
    else
      prepare_show_vars
      render :show, status: :unprocessable_entity
    end
  rescue Date::Error
    @book.errors.add(:deadline, :invalid)
    prepare_show_vars
    render :show, status: :unprocessable_entity
  end

  def complete
    completed_at = @book.completed_at || Time.current
    previous_page = @book.current_page.to_i
    success = false

    Book.transaction do
      success = @book.update(status: :completed, current_page: @book.target_pages, completed_at: completed_at)
      raise ActiveRecord::Rollback unless success

      create_reading_log_for_completion!(previous_page)
    end

    if success
      flash[:completed_book] = @book.title
      redirect_to @book
    else
      prepare_show_vars
      render :show, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordInvalid
    @book.reload
    @book.errors.add(:base, "読書ログの記録に失敗しました")
    prepare_show_vars
    render :show, status: :unprocessable_entity
  end

  def destroy
    @book.destroy
    redirect_to books_path, notice: "#{@book.title}を削除しました。", status: :see_other
  end

  def update_review
    if @book.update(review_params)
      redirect_to @book, notice: "評価・感想を保存しました。"
    else
      prepare_show_vars
      render :show, status: :unprocessable_entity
    end
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

  SUGGESTION_FIELDS = %w[author genre].freeze

  def suggestions
    field = params[:field].to_s
    return render json: { error: "Invalid field" }, status: :bad_request unless SUGGESTION_FIELDS.include?(field)

    query = params[:q].to_s.strip
    results = current_user.books
                          .where.not(field => [ nil, "" ])
                          .where("#{field} ILIKE ?", "%#{Book.sanitize_sql_like(query)}%")
                          .order(field)
                          .distinct
                          .limit(5)
                          .pluck(field)
    render json: { suggestions: results }
  end

  def cover_proxy
    url = params[:url].to_s
    escaped_url = url.inspect
    uri = URI.parse(url)
    unless ALLOWED_COVER_HOSTS.include?(uri.host)
      Rails.logger.warn("[BooksController#cover_proxy] forbidden_host url=#{escaped_url}")
      return head :forbidden
    end

    result = fetch_with_redirects(uri)
    case result
    when :forbidden
      Rails.logger.warn("[BooksController#cover_proxy] forbidden_redirect url=#{escaped_url}")
      head :forbidden
    when Net::HTTPResponse
      content_type = result["content-type"] || "image/jpeg"
      send_data result.body, type: content_type, disposition: "inline"
    else
      Rails.logger.warn("[BooksController#cover_proxy] image_not_found url=#{escaped_url}")
      head :not_found
    end
  rescue URI::InvalidURIError
    Rails.logger.warn("[BooksController#cover_proxy] invalid_url url=#{escaped_url}")
    head :bad_request
  rescue Net::OpenTimeout, Net::ReadTimeout
    Rails.logger.warn("[BooksController#cover_proxy] timeout url=#{escaped_url}")
    head :not_found
  rescue StandardError => e
    Rails.logger.error("[BooksController#cover_proxy] fetch_failed url=#{escaped_url} error=#{e.class}: #{e.message}")
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
      return nil if location.blank?

      redirect_uri = URI.join(uri.to_s, location)
      return :forbidden unless ALLOWED_REDIRECT_HOSTS.include?(redirect_uri.host)

      fetch_with_redirects(redirect_uri, redirect_count + 1)
    elsif response.is_a?(Net::HTTPSuccess)
      response
    end
  rescue URI::InvalidURIError, TypeError => e
    Rails.logger.warn("[BooksController#fetch_with_redirects] invalid_redirect_uri uri=#{uri} error=#{e.class}: #{e.message}")
    nil
  end

  def set_book
    @book = current_user.books.find_by(id: params[:id])
    render file: Rails.public_path.join("404.html"), status: :not_found, layout: false unless @book
  end

  def prepare_show_vars
    @book_memos = @book.book_memos.latest_first
    @new_book_memo = @book.book_memos.build
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

  def persist_progress_with_log(new_page)
    success = false

    Book.transaction do
      success = @book.update(current_page: new_page)
      raise ActiveRecord::Rollback unless success

      create_reading_log_for_progress!
    end

    success
  rescue ActiveRecord::RecordInvalid
    @book.errors.add(:base, "読書ログの記録に失敗しました")
    false
  end

  def create_reading_log_for_progress!
    previous_page, current_page = @book.saved_change_to_current_page
    pages_read = current_page.to_i - previous_page.to_i
    return if pages_read <= 0

    @book.reading_logs.create!(
      pages_read: pages_read,
      read_at: Date.current,
      start_page: previous_page.to_i + 1,
      end_page: current_page.to_i
    )
  end

  def create_reading_log_for_completion!(previous_page)
    current_page = @book.current_page.to_i
    pages_read = current_page - previous_page.to_i
    return if pages_read <= 0

    @book.reading_logs.create!(
      pages_read: pages_read,
      read_at: Date.current,
      start_page: previous_page.to_i + 1,
      end_page: current_page
    )
  end

  def book_params
    permitted = params.require(:book).permit(:title, :author, :genre, :total_pages, :target_pages, :current_page, :deadline, :status, :cover_image_url, :cover_image, :isbn, :memo, :is_past_reading, :completed_at_input)
    permitted[:current_page] = 0 if permitted[:current_page].blank?
      permitted
  end

  def edit_book_params
    params.require(:book).permit(:title, :author, :genre, :total_pages, :target_pages, :deadline, :cover_image_url, :cover_image, :isbn)
  end

  def memo_params
    params.require(:book).permit(:memo)
  end

  def review_params
    params.require(:book).permit(:rating, :review)
  end

  def normalized_index_search_params
    permitted = params.permit(:title, :author, :genre, :completed_from, :completed_to)
    title = permitted[:title].to_s.strip
    author = permitted[:author].to_s.strip
    genre = permitted[:genre].to_s.strip
    completed_from = parse_iso_date(permitted[:completed_from])
    completed_to = parse_iso_date(permitted[:completed_to])

    if completed_from.present? && completed_to.present? && completed_from > completed_to
      completed_from, completed_to = completed_to, completed_from
    end

    {
      title: title.presence,
      author: author.presence,
      genre: genre.presence,
      completed_from: completed_from,
      completed_to: completed_to
    }
  end

  def parse_iso_date(value)
    return nil if value.blank?

    Date.iso8601(value)
  rescue ArgumentError
    nil
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
      genre: extract_openbd_genre(book),
      total_pages: total_pages,
      cover_image_url: cover_image_url,
      isbn: isbn
    } ]
  end

  def search_by_title(title)
    uri = URI("https://www.googleapis.com/books/v1/volumes")
    query_params = { q: "intitle:#{title}", langRestrict: "ja", maxResults: 5 }
    api_key = ENV["GOOGLE_BOOKS_API_KEY"].presence
    query_params[:key] = api_key if api_key
    uri.query = URI.encode_www_form(query_params)
    data = fetch_title_json(uri.to_s)
    items = data&.dig("items") || []

    items.map do |item|
      info = item["volumeInfo"] || {}
      isbn = extract_isbn_from_identifiers(info["industryIdentifiers"])
      openbd_book = lookup_openbd_book(isbn)
      openbd_url = openbd_book&.dig("summary", "cover").to_s.presence || ""
      google_cover_url = best_google_image_url(info["imageLinks"])
      genre = extract_google_books_genre(info)
      genre = extract_openbd_genre(openbd_book) if genre.blank?
      {
        title: info["title"].to_s,
        author: Array(info["authors"]).join(", "),
        genre: genre,
        total_pages: info["pageCount"],
        cover_image_url: resolve_cover_url(openbd_url, isbn, google_cover_url),
        isbn: isbn.to_s.presence || ""
      }
    end
  end

  def extract_openbd_genre(book)
    return "" if book.blank?

    summary_genre = book.dig("summary", "genre").to_s.strip
    return summary_genre if summary_genre.present?

    subjects = book.dig("onix", "DescriptiveDetail", "Subject")
    subjects = subjects.is_a?(Array) ? subjects : [ subjects ].compact
    subjects.each do |subject|
      next unless subject.is_a?(Hash)

      heading = subject["SubjectHeadingText"]
      values = heading.is_a?(Array) ? heading : [ heading ]
      candidate = values.map { |value| value.to_s.strip }.find(&:present?)
      return candidate if candidate
    end

    ""
  end

  def extract_google_books_genre(info)
    Array(info["categories"]).map { |category| category.to_s.strip }.find(&:present?).to_s
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

  def lookup_openbd_book(isbn)
    return nil if isbn.blank?

    data = fetch_json("https://api.openbd.jp/v1/get?isbn=#{isbn}")
    return nil if data.nil? || data.first.nil?

    data.first
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
    image_links = data&.dig("items", 0, "volumeInfo", "imageLinks")
    best_google_image_url(image_links)
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

  def best_google_image_url(image_links)
    return "" if image_links.blank?

    %w[extraLarge large medium small thumbnail smallThumbnail].each do |size|
      url = image_links[size].to_s.presence
      return url.sub(/\Ahttp:/, "https:") if url
    end
    ""
  end
end
