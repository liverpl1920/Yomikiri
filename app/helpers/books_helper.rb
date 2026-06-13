# frozen_string_literal: true

module BooksHelper
  # book の書影表示用 src を返す。
  # - cover_image（Active Storage）が添付されている場合はそのURLを返す
  # - books.google.com ホストの cover_image_url の場合は cover_proxy エンドポイント経由の URL を返す
  # - それ以外は cover_image_url をそのまま返す
  # - 書影が存在しない場合は nil を返す
  def book_cover_src(book)
    if book.cover_image.attached?
      begin
        url_for(book.cover_image)
      rescue StandardError => e
        Rails.logger.warn("[BooksHelper#book_cover_src] active_storage_url_failed book_id=#{book.id} error=#{e.class}: #{e.message}")
        nil
      end
    elsif book.cover_image_url.present?
      begin
        uri = URI.parse(book.cover_image_url)
        unless uri.is_a?(URI::HTTP) && uri.host.present?
          Rails.logger.warn("[BooksHelper#book_cover_src] invalid_cover_image_url book_id=#{book.id} url=#{book.cover_image_url.inspect}")
          return nil
        end

        if uri.host == "books.google.com"
          cover_proxy_books_path(url: book.cover_image_url)
        else
          book.cover_image_url
        end
      rescue URI::InvalidURIError
        Rails.logger.warn("[BooksHelper#book_cover_src] invalid_cover_image_url book_id=#{book.id} url=#{book.cover_image_url.inspect}")
        nil
      end
    end
  end

  # 一覧画面の書籍カード用著者表示文字列を返す。
  # 著者が複数人いる場合は1人目のみ表示し、末尾に " ..." を付加する。
  # 著者が1人または未設定の場合はそのまま返す。
  def book_author_display(book)
    authors = book.authors
    if authors.length > 1
      "#{authors.first} ..."
    else
      book.author.to_s
    end
  end
end
