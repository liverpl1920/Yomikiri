# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Books Search', type: :request do
  let(:user) { create(:user) }

  let(:openbd_found_response) do
    [ {
      'summary' => {
        'isbn' => '9784873115658',
        'title' => 'リーダブルコード',
        'author' => 'Dustin Boswell'
      },
      'onix' => {
        'DescriptiveDetail' => {
          'Extent' => [
            { 'ExtentType' => '11', 'ExtentValue' => '260' }
          ]
        }
      }
    } ].to_json
  end

  let(:openbd_not_found_response) { [ nil ].to_json }

  let(:google_books_response) do
    {
      'items' => [
        {
          'volumeInfo' => {
            'title' => 'リーダブルコード',
            'authors' => [ 'Dustin Boswell', 'Trevor Foucher' ],
            'pageCount' => 260,
            'industryIdentifiers' => [
              { 'type' => 'ISBN_13', 'identifier' => '9784873115658' }
            ],
            'imageLinks' => {
              'thumbnail' => 'http://books.google.com/books/content?id=abc&printsec=frontcover&img=1'
            }
          }
        },
        {
          'volumeInfo' => {
            'title' => 'リーダブルコード 実践編',
            'authors' => [ '山田太郎' ],
            'pageCount' => 200,
            'industryIdentifiers' => []
          }
        }
      ]
    }.to_json
  end

  describe 'GET /books/search' do
    context '未ログインの場合' do
      it 'ログイン画面へリダイレクトされる' do
        get search_books_path, params: { q: '9784873115658' }

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'ログイン済みの場合' do
      before { sign_in user }

      context 'クエリが空の場合' do
        it '空の書籍配列を返す' do
          get search_books_path, params: { q: '' }

          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          expect(json['books']).to eq([])
        end
      end

      context 'ISBNで検索する場合' do
        before do
          stub_request(:get, /api\.openbd\.jp\/v1\/get\?isbn=9784873115658/)
            .to_return(status: 200, body: openbd_found_response, headers: { 'Content-Type' => 'application/json' })
        end

        it '200 OK を返す' do
          get search_books_path, params: { q: '9784873115658' }

          expect(response).to have_http_status(:ok)
        end

        it '書籍情報を含むJSONを返す' do
          get search_books_path, params: { q: '9784873115658' }

          json = JSON.parse(response.body)
          expect(json['books'].length).to eq(1)
          book = json['books'].first
          expect(book['title']).to eq('リーダブルコード')
          expect(book['author']).to eq('Dustin Boswell')
          expect(book['total_pages']).to eq(260)
          expect(book['cover_image_url']).to eq('https://cover.openbd.jp/9784873115658.jpg')
        end

        it 'ハイフン付きISBNでも検索できる' do
          stub_request(:get, /api\.openbd\.jp\/v1\/get\?isbn=9784873115658/)
            .to_return(status: 200, body: openbd_found_response, headers: { 'Content-Type' => 'application/json' })

          get search_books_path, params: { q: '978-4-87311-565-8' }

          json = JSON.parse(response.body)
          expect(json['books'].length).to eq(1)
        end

        it 'ISBN-10で検索しても書影URLはAPIのISBN-13を使う' do
          stub_request(:get, /api\.openbd\.jp\/v1\/get\?isbn=4873115655/)
            .to_return(status: 200, body: openbd_found_response, headers: { 'Content-Type' => 'application/json' })

          get search_books_path, params: { q: '4873115655' }

          json = JSON.parse(response.body)
          book = json['books'].first
          expect(book['cover_image_url']).to eq('https://cover.openbd.jp/9784873115658.jpg')
        end
      end

      context 'openBDに存在しないISBNの場合' do
        before do
          stub_request(:get, /api\.openbd\.jp\/v1\/get\?isbn=0000000000000/)
            .to_return(status: 200, body: openbd_not_found_response, headers: { 'Content-Type' => 'application/json' })
        end

        it '空の書籍配列を返す' do
          get search_books_path, params: { q: '0000000000000' }

          json = JSON.parse(response.body)
          expect(json['books']).to eq([])
        end
      end

      context 'openBD APIがタイムアウトした場合' do
        before do
          stub_request(:get, /api\.openbd\.jp/).to_timeout
        end

        it '空の書籍配列を返す' do
          get search_books_path, params: { q: '9784873115658' }

          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          expect(json['books']).to eq([])
        end
      end

      context '書籍名で検索する場合' do
        before do
          stub_request(:get, /www\.googleapis\.com\/books\/v1\/volumes/)
            .to_return(status: 200, body: google_books_response, headers: { 'Content-Type' => 'application/json' })
        end

        it '200 OK を返す' do
          get search_books_path, params: { q: 'リーダブルコード' }

          expect(response).to have_http_status(:ok)
        end

        it '複数の候補を返す' do
          get search_books_path, params: { q: 'リーダブルコード' }

          json = JSON.parse(response.body)
          expect(json['books'].length).to eq(2)
        end

        it '最初の候補の情報が正しい' do
          get search_books_path, params: { q: 'リーダブルコード' }

          json = JSON.parse(response.body)
          book = json['books'].first
          expect(book['title']).to eq('リーダブルコード')
          expect(book['author']).to eq('Dustin Boswell, Trevor Foucher')
          expect(book['total_pages']).to eq(260)
          expect(book['cover_image_url']).to eq('https://books.google.com/books/content?id=abc&printsec=frontcover&img=1')
        end

        it '書影URLのhttp:// は https:// に変換される' do
          get search_books_path, params: { q: 'リーダブルコード' }

          json = JSON.parse(response.body)
          book = json['books'].first
          expect(book['cover_image_url']).to start_with('https://')
        end

        it 'imageLinksがない候補は書影URLが空文字' do
          get search_books_path, params: { q: 'リーダブルコード' }

          json = JSON.parse(response.body)
          second_book = json['books'][1]
          expect(second_book['cover_image_url']).to eq('')
        end

        it '11桁の数値クエリはISBN扱いせずタイトル検索される' do
          get search_books_path, params: { q: '12345678901' }

          json = JSON.parse(response.body)
          expect(json['books'].length).to eq(2)
        end
      end

      context 'Google Books APIが429を返した場合' do
        before do
          stub_request(:get, /www\.googleapis\.com\/books\/v1\/volumes/)
            .to_return(status: 429, body: '', headers: {})
        end

        it '200 OK を返す' do
          get search_books_path, params: { q: 'リーダブルコード' }

          expect(response).to have_http_status(:ok)
        end

        it 'booksが空配列でerrorキーを含むJSONを返す' do
          get search_books_path, params: { q: 'リーダブルコード' }

          json = JSON.parse(response.body)
          expect(json['books']).to eq([])
          expect(json['error']).to be_present
        end

        it 'errorメッセージにレートリミットを示す文言が含まれる' do
          get search_books_path, params: { q: 'リーダブルコード' }

          json = JSON.parse(response.body)
          expect(json['error']).to include('制限')
        end
      end

      context 'Google Books APIが503を返した場合' do
        before do
          stub_request(:get, /www\.googleapis\.com\/books\/v1\/volumes/)
            .to_return(status: 503, body: '', headers: {})
        end

        it 'booksが空配列でerrorキーを含むJSONを返す' do
          get search_books_path, params: { q: 'リーダブルコード' }

          json = JSON.parse(response.body)
          expect(json['books']).to eq([])
          expect(json['error']).to be_present
        end
      end

      context 'Google Books APIがタイムアウトした場合' do
        before do
          stub_request(:get, /www\.googleapis\.com\/books\/v1\/volumes/).to_timeout
        end

        it 'booksが空配列でerrorキーを含むJSONを返す' do
          get search_books_path, params: { q: 'リーダブルコード' }

          json = JSON.parse(response.body)
          expect(json['books']).to eq([])
          expect(json['error']).to include('タイムアウト')
        end
      end
    end
  end
end
