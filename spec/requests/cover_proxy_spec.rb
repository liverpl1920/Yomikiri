# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Books Cover Proxy', type: :request do
  let(:user) { create(:user) }
  let(:google_image_url) { 'https://books.google.com/books/content?id=abc&printsec=frontcover&img=1' }
  let(:image_body) { "\xFF\xD8\xFF\xE0fake_jpeg_data".b }

  describe 'GET /books/cover_proxy' do
    context '未ログインの場合' do
      it 'ログイン画面へリダイレクトされる' do
        get cover_proxy_books_path, params: { url: google_image_url }

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'ログイン済みの場合' do
      before { sign_in user }

      context 'books.google.com の URL の場合' do
        before do
          stub_request(:get, google_image_url)
            .to_return(status: 200, body: image_body,
                       headers: { 'Content-Type' => 'image/jpeg' })
        end

        it '200 OK を返す' do
          get cover_proxy_books_path, params: { url: google_image_url }

          expect(response).to have_http_status(:ok)
        end

        it '画像データをそのまま返す' do
          get cover_proxy_books_path, params: { url: google_image_url }

          expect(response.body).to eq(image_body)
        end

        it 'Content-Type が image/jpeg である' do
          get cover_proxy_books_path, params: { url: google_image_url }

          expect(response.content_type).to include('image/jpeg')
        end
      end

      context 'books.google.com 以外のドメインの場合' do
        it '403 Forbidden を返す' do
          get cover_proxy_books_path, params: { url: 'https://example.com/image.jpg' }

          expect(response).to have_http_status(:forbidden)
        end

        it 'internal IP アドレスも拒否する' do
          get cover_proxy_books_path, params: { url: 'http://169.254.169.254/metadata' }

          expect(response).to have_http_status(:forbidden)
        end
      end

      context '不正な URL の場合' do
        it '400 Bad Request を返す' do
          get cover_proxy_books_path, params: { url: 'not a valid url' }

          expect(response).to have_http_status(:bad_request)
        end
      end

      context '画像取得がタイムアウトした場合' do
        before do
          stub_request(:get, google_image_url).to_timeout
        end

        it '404 Not Found を返す' do
          get cover_proxy_books_path, params: { url: google_image_url }

          expect(response).to have_http_status(:not_found)
        end
      end

      context '画像取得が HTTP エラーを返した場合' do
        before do
          stub_request(:get, google_image_url)
            .to_return(status: 404, body: 'Not Found')
        end

        it '404 Not Found を返す' do
          get cover_proxy_books_path, params: { url: google_image_url }

          expect(response).to have_http_status(:not_found)
        end
      end

      context 'サーバーエラーが返った場合' do
        before do
          stub_request(:get, google_image_url)
            .to_return(status: 500, body: 'Internal Server Error')
        end

        it '404 Not Found を返す' do
          get cover_proxy_books_path, params: { url: google_image_url }

          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end
end
