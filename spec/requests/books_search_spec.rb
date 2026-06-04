# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Books Search', type: :request do
  let(:user) { create(:user) }

  let(:openbd_found_response) do
    [ {
      'summary' => {
        'isbn' => '9784873115658',
        'title' => 'リーダブルコード',
        'author' => 'Dustin Boswell',
        'publisher' => 'オライリー・ジャパン',
        'cover' => 'https://cover.openbd.jp/9784873115658.jpg'
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
            'publisher' => 'オライリー・ジャパン',
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
          expect(book['pages']).to eq(260)
          expect(book['publisher']).to eq('オライリー・ジャパン')
          expect(book['cover_image_url']).to eq('https://cover.openbd.jp/9784873115658.jpg')
        end

        it '検索結果にisbnキーが含まれる' do
          get search_books_path, params: { q: '9784873115658' }

          json = JSON.parse(response.body)
          book = json['books'].first
          expect(book).to have_key('isbn')
          expect(book['isbn']).to eq('9784873115658')
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
          stub_request(:get, /api\.openbd\.jp\/v1\/get\?isbn=9784873115658/)
            .to_return(status: 200, body: openbd_found_response, headers: { 'Content-Type' => 'application/json' })
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
          expect(book['pages']).to eq(260)
          expect(book['publisher']).to eq('オライリー・ジャパン')
          expect(book['cover_image_url']).to eq('https://cover.openbd.jp/9784873115658.jpg')
        end

        it 'タイトル検索結果にisbnキーが含まれる' do
          get search_books_path, params: { q: 'リーダブルコード' }

          json = JSON.parse(response.body)
          book = json['books'].first
          expect(book).to have_key('isbn')
          expect(book['isbn']).to eq('9784873115658')
        end

        it 'Google thumbnailではなくopenBDの書影URLを優先する' do
          get search_books_path, params: { q: 'リーダブルコード' }

          json = JSON.parse(response.body)
          book = json['books'].first
          expect(book['cover_image_url']).to start_with('https://cover.openbd.jp/')
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

        it 'GOOGLE_BOOKS_API_KEY が設定されている場合は key パラメータ付きで Google Books を呼ぶ' do
          stub_const('ENV', ENV.to_h.merge('GOOGLE_BOOKS_API_KEY' => 'test_google_api_key'))

          get search_books_path, params: { q: 'リーダブルコード' }

          expect(WebMock).to have_requested(:get, /www\.googleapis\.com\/books\/v1\/volumes/)
            .with { |request| request.uri.query.to_s.include?('key=test_google_api_key') }
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

      context 'openBDに書影がなくGoogle Books thumbnailがある場合' do
        let(:google_books_thumbnail_only_response) do
          {
            'items' => [
              {
                'volumeInfo' => {
                  'title' => 'サムネイル書籍',
                  'authors' => [ '著者名' ],
                  'pageCount' => 100,
                  'industryIdentifiers' => [
                    { 'type' => 'ISBN_13', 'identifier' => '9780000000001' }
                  ],
                  'imageLinks' => {
                    'thumbnail' => 'http://books.google.com/books/content?id=xyz&img=1'
                  }
                }
              }
            ]
          }.to_json
        end

        before do
          stub_request(:get, /www\.googleapis\.com\/books\/v1\/volumes/)
            .to_return(status: 200, body: google_books_thumbnail_only_response,
                       headers: { 'Content-Type' => 'application/json' })
          stub_request(:get, /api\.openbd\.jp\/v1\/get\?isbn=9780000000001/)
            .to_return(status: 200, body: [ nil ].to_json,
                       headers: { 'Content-Type' => 'application/json' })
        end

        it 'Google Books thumbnail URL（https正規化済み）を返す' do
          get search_books_path, params: { q: 'サムネイル書籍' }

          json = JSON.parse(response.body)
          book = json['books'].first
          expect(book['cover_image_url']).to eq('https://books.google.com/books/content?id=xyz&img=1')
        end
      end

      context 'openBDのSubjectが単一Hashでもジャンルを抽出できる場合' do
        let(:google_books_subject_hash_response) do
          {
            'items' => [
              {
                'volumeInfo' => {
                  'title' => 'Subject Hash 本',
                  'authors' => [ '著者名' ],
                  'pageCount' => 100,
                  'industryIdentifiers' => [
                    { 'type' => 'ISBN_13', 'identifier' => '9780000000002' }
                  ]
                }
              }
            ]
          }.to_json
        end

        let(:openbd_subject_hash_response) do
          [ {
            'summary' => {
              'isbn' => '9780000000002',
              'title' => 'Subject Hash 本',
              'author' => '著者名'
            },
            'onix' => {
              'DescriptiveDetail' => {
                'Subject' => {
                  'SubjectHeadingText' => '技術・工学'
                }
              }
            }
          } ].to_json
        end

        before do
          stub_request(:get, /www\.googleapis\.com\/books\/v1\/volumes/)
            .to_return(status: 200, body: google_books_subject_hash_response,
                       headers: { 'Content-Type' => 'application/json' })
          stub_request(:get, /api\.openbd\.jp\/v1\/get\?isbn=9780000000002/)
            .to_return(status: 200, body: openbd_subject_hash_response,
                       headers: { 'Content-Type' => 'application/json' })
        end

        it 'TypeErrorにならずジャンルを返す' do
          get search_books_path, params: { q: 'Subject Hash 本' }

          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          expect(json['books'].first['genre']).to eq('技術・工学')
        end
      end

      context 'openBDに書影があればopenBD URLを優先する' do
        before do
          stub_request(:get, /www\.googleapis\.com\/books\/v1\/volumes/)
            .to_return(status: 200, body: google_books_response,
                       headers: { 'Content-Type' => 'application/json' })
          stub_request(:get, /api\.openbd\.jp\/v1\/get\?isbn=9784873115658/)
            .to_return(status: 200, body: openbd_found_response,
                       headers: { 'Content-Type' => 'application/json' })
        end

        it 'openBD URLを返し、Google thumbnail URLは返さない' do
          get search_books_path, params: { q: 'リーダブルコード' }

          json = JSON.parse(response.body)
          book = json['books'].first
          expect(book['cover_image_url']).to start_with('https://cover.openbd.jp/')
          expect(book['cover_image_url']).not_to include('books.google.com')
        end
      end

      context 'ISBNで検索してopenBDに書影がなく楽天に書影がある場合' do
        let(:openbd_no_cover_response) do
          [ {
            'summary' => {
              'isbn' => '',
              'title' => '楽天書籍',
              'author' => '著者'
            },
            'onix' => {}
          } ].to_json
        end

        let(:rakuten_cover_response) do
          {
            'Items' => [
              {
                'Item' => {
                  'largeImageUrl' => 'https://thumbnail.image.rakuten.co.jp/rakuten/large.jpg',
                  'mediumImageUrl' => 'https://thumbnail.image.rakuten.co.jp/rakuten/medium.jpg'
                }
              }
            ]
          }.to_json
        end

        before do
          stub_request(:get, /api\.openbd\.jp\/v1\/get\?isbn=9784873115658/)
            .to_return(status: 200, body: openbd_no_cover_response,
                       headers: { 'Content-Type' => 'application/json' })
          stub_request(:get, /app\.rakuten\.co\.jp\/services\/api\/BooksBook/)
            .to_return(status: 200, body: rakuten_cover_response,
                       headers: { 'Content-Type' => 'application/json' })
        end

        it '楽天の書影URLを返す' do
          stub_const('ENV', ENV.to_h.merge('RAKUTEN_APPLICATION_ID' => 'test_app_id'))

          get search_books_path, params: { q: '9784873115658' }

          json = JSON.parse(response.body)
          book = json['books'].first
          expect(book['cover_image_url']).to eq('https://thumbnail.image.rakuten.co.jp/rakuten/large.jpg')
        end
      end

      context 'ISBNで検索してopenBD・楽天に書影がなくGoogle Booksに書影がある場合' do
        let(:openbd_no_cover_response) do
          [ {
            'summary' => { 'isbn' => '', 'title' => 'Google書籍', 'author' => '著者' },
            'onix' => {}
          } ].to_json
        end

        let(:google_isbn_cover_response) do
          {
            'items' => [
              {
                'volumeInfo' => {
                  'imageLinks' => {
                    'thumbnail' => 'http://books.google.com/books/content?id=goog&img=1'
                  }
                }
              }
            ]
          }.to_json
        end

        before do
          stub_request(:get, /api\.openbd\.jp\/v1\/get\?isbn=9784873115658/)
            .to_return(status: 200, body: openbd_no_cover_response,
                       headers: { 'Content-Type' => 'application/json' })
          stub_request(:get, /www\.googleapis\.com\/books\/v1\/volumes.*q=isbn/)
            .to_return(status: 200, body: google_isbn_cover_response,
                       headers: { 'Content-Type' => 'application/json' })
        end

        it 'Google Books thumbnail URL（https正規化済み）を返す' do
          get search_books_path, params: { q: '9784873115658' }

          json = JSON.parse(response.body)
          book = json['books'].first
          expect(book['cover_image_url']).to eq('https://books.google.com/books/content?id=goog&img=1')
        end
      end

      context 'ISBNで検索して全ソースに書影がない場合' do
        let(:openbd_no_cover_response) do
          [ {
            'summary' => { 'isbn' => '', 'title' => '書影なし書籍', 'author' => '著者' },
            'onix' => {}
          } ].to_json
        end

        before do
          stub_request(:get, /api\.openbd\.jp\/v1\/get\?isbn=9784873115658/)
            .to_return(status: 200, body: openbd_no_cover_response,
                       headers: { 'Content-Type' => 'application/json' })
          stub_request(:get, /www\.googleapis\.com\/books\/v1\/volumes.*q=isbn/)
            .to_return(status: 200, body: { 'items' => [] }.to_json,
                       headers: { 'Content-Type' => 'application/json' })
        end

        it '書影URLが空文字を返す' do
          get search_books_path, params: { q: '9784873115658' }

          json = JSON.parse(response.body)
          book = json['books'].first
          expect(book['cover_image_url']).to eq('')
        end
      end

      context 'タイトル検索でopenBDに書影がなく楽天に書影がある場合' do
        let(:google_books_no_openbd_response) do
          {
            'items' => [
              {
                'volumeInfo' => {
                  'title' => '楽天書籍タイトル',
                  'authors' => [ '著者名' ],
                  'pageCount' => 200,
                  'industryIdentifiers' => [
                    { 'type' => 'ISBN_13', 'identifier' => '9784000000001' }
                  ],
                  'imageLinks' => {
                    'thumbnail' => 'http://books.google.com/books/content?id=abc&img=1'
                  }
                }
              }
            ]
          }.to_json
        end

        let(:rakuten_cover_response) do
          {
            'Items' => [
              {
                'Item' => {
                  'largeImageUrl' => 'https://thumbnail.image.rakuten.co.jp/rakuten/title_large.jpg',
                  'mediumImageUrl' => 'https://thumbnail.image.rakuten.co.jp/rakuten/title_medium.jpg'
                }
              }
            ]
          }.to_json
        end

        before do
          stub_request(:get, /www\.googleapis\.com\/books\/v1\/volumes.*q=intitle/)
            .to_return(status: 200, body: google_books_no_openbd_response,
                       headers: { 'Content-Type' => 'application/json' })
          stub_request(:get, /api\.openbd\.jp\/v1\/get\?isbn=9784000000001/)
            .to_return(status: 200, body: [ nil ].to_json,
                       headers: { 'Content-Type' => 'application/json' })
          stub_request(:get, /app\.rakuten\.co\.jp\/services\/api\/BooksBook/)
            .to_return(status: 200, body: rakuten_cover_response,
                       headers: { 'Content-Type' => 'application/json' })
        end

        it '楽天の書影URLを返す' do
          stub_const('ENV', ENV.to_h.merge('RAKUTEN_APPLICATION_ID' => 'test_app_id'))

          get search_books_path, params: { q: '楽天書籍タイトル' }

          json = JSON.parse(response.body)
          book = json['books'].first
          expect(book['cover_image_url']).to eq('https://thumbnail.image.rakuten.co.jp/rakuten/title_large.jpg')
        end
      end

      context 'RAKUTEN_APPLICATION_ID が未設定の場合は楽天をスキップする' do
        let(:openbd_no_cover_response) do
          [ {
            'summary' => { 'isbn' => '', 'title' => 'スキップ書籍', 'author' => '著者' },
            'onix' => {}
          } ].to_json
        end

        let(:google_isbn_cover_response) do
          {
            'items' => [
              {
                'volumeInfo' => {
                  'imageLinks' => {
                    'thumbnail' => 'http://books.google.com/books/content?id=skip&img=1'
                  }
                }
              }
            ]
          }.to_json
        end

        before do
          stub_request(:get, /api\.openbd\.jp\/v1\/get\?isbn=9784873115658/)
            .to_return(status: 200, body: openbd_no_cover_response,
                       headers: { 'Content-Type' => 'application/json' })
          stub_request(:get, /www\.googleapis\.com\/books\/v1\/volumes.*q=isbn/)
            .to_return(status: 200, body: google_isbn_cover_response,
                       headers: { 'Content-Type' => 'application/json' })
        end

        it '楽天APIを呼ばずにGoogle Books URLを返す' do
          get search_books_path, params: { q: '9784873115658' }

          json = JSON.parse(response.body)
          book = json['books'].first
          expect(book['cover_image_url']).to eq('https://books.google.com/books/content?id=skip&img=1')
          expect(WebMock).not_to have_requested(:get, /app\.rakuten\.co\.jp/)
        end
      end
    end
  end
end
