# frozen_string_literal: true

module BooksHelper
  # book の書影表示用 src を返す。
  # - cover_image（Active Storage）が添付されている場合はそのURLを返す
  # - books.google.com ホストの cover_image_url の場合は cover_proxy エンドポイント経由の URL を返す
  # - それ以外は cover_image_url をそのまま返す
  # - 書影が存在しない場合は nil を返す
  def book_cover_src(book)
    if book.cover_image.attached?
      url_for(book.cover_image)
    elsif book.cover_image_url.present?
      begin
        uri = URI.parse(book.cover_image_url)
        if uri.host == "books.google.com"
          cover_proxy_books_path(url: book.cover_image_url)
        else
          book.cover_image_url
        end
      rescue URI::InvalidURIError
        nil
      end
    end
  end
end
