# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BooksHelper, type: :helper do
  describe '#book_cover_src' do
    let(:book) { create(:book, cover_image_url: 'https://example.com/fallback.jpg') }

    it 'cover_image 添付時は cover_image_url より添付URLを優先する' do
      book.cover_image.attach(
        io: StringIO.new('fake png data'),
        filename: 'cover.png',
        content_type: 'image/png'
      )
      allow(helper).to receive(:url_for).with(book.cover_image).and_return('/rails/active_storage/blobs/cover.png')

      expect(helper.book_cover_src(book)).to eq('/rails/active_storage/blobs/cover.png')
    end

    it 'books.google.com の URL は cover_proxy 経由に変換する' do
      google_url = 'https://books.google.com/books/content?id=abc123'
      target_book = create(:book, cover_image_url: google_url)

      expect(helper.book_cover_src(target_book)).to eq(helper.cover_proxy_books_path(url: google_url))
    end

    it '不正なURLの場合は nil を返し warn ログを出力する' do
      target_book = build(:book)
      target_book.cover_image_url = 'not-a-valid-url'
      allow(Rails.logger).to receive(:warn)

      expect(helper.book_cover_src(target_book)).to be_nil
      expect(Rails.logger).to have_received(:warn).with(/invalid_cover_image_url/)
    end

    it '添付URL生成に失敗した場合は nil を返し warn ログを出力する' do
      book.cover_image.attach(
        io: StringIO.new('fake png data'),
        filename: 'cover.png',
        content_type: 'image/png'
      )
      allow(helper).to receive(:url_for).with(book.cover_image).and_raise(StandardError, 'blob missing')
      allow(Rails.logger).to receive(:warn)

      expect(helper.book_cover_src(book)).to be_nil
      expect(Rails.logger).to have_received(:warn).with(/active_storage_url_failed/)
    end
  end
end
