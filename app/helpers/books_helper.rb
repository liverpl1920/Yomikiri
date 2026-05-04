# frozen_string_literal: true

module BooksHelper
  # cover_image_url に応じた書影表示用 src を返す。
  # - books.google.com ホストの場合は cover_proxy エンドポイント経由の URL を返す
  # - それ以外は URL をそのまま返す
  # - nil / 空文字 / 不正 URI の場合は nil を返す
  def book_cover_src(cover_image_url)
    return nil if cover_image_url.blank?

    uri = URI.parse(cover_image_url)
    if uri.host == "books.google.com"
      cover_proxy_books_path(url: cover_image_url)
    else
      cover_image_url
    end
  rescue URI::InvalidURIError
    nil
  end
end
