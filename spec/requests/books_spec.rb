# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Books', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  describe 'GET /books' do
    context '未ログインの場合' do
      it 'ログイン画面へリダイレクトされる' do
        get books_path

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'ログイン済みの場合' do
      before { sign_in user }

      context '書籍が0冊の場合' do
        it '200 OK を返す' do
          get books_path

          expect(response).to have_http_status(:ok)
        end

        it 'Empty State を表示する' do
          get books_path

          expect(response.body).to include('積読本はまだありません')
          expect(response.body).to include('最初の本を登録して始める')
        end

        it 'Empty State のボタンが new_book_path へのリンクである' do
          get books_path

          empty_state_link = response.body.scan(%r{<a\b[^>]*href="[^"]*"[^>]*>.*?</a>}m).find do |anchor|
            anchor.include?(%(href="#{new_book_path}")) &&
              anchor.gsub(/<[^>]+>/, ' ').gsub(/\s+/, ' ').include?('最初の本を登録して始める')
          end

          expect(empty_state_link).to be_present
          expect(empty_state_link).not_to match(/\bdisabled\b/)
        end
      end

      context '書籍が複数ある場合' do
        let!(:book_far) { create(:book, user: user, title: '遠い期限の本', deadline: Date.current + 30, status: :unread) }
        let!(:book_near) { create(:book, user: user, title: '近い期限の本', deadline: Date.current + 3, status: :reading) }
        let!(:book_completed) do
          create(:book, user: user, title: '読了済みの本', deadline: Date.current + 5, status: :completed, rating: 4)
        end
        let!(:book_completed_without_rating) do
          create(:book, user: user, title: '評価未設定の読了本', deadline: Date.current + 8, status: :completed, rating: nil)
        end

        it '200 OK を返す' do
          get books_path

          expect(response).to have_http_status(:ok)
        end

        it 'ヘッダーの「+ 本を追加する」ボタンが new_book_path へのリンクである' do
          get books_path

          add_book_link = response.body.scan(%r{<a\b[^>]*href="[^"]*"[^>]*>.*?</a>}m).find do |anchor|
            anchor.include?(%(href="#{new_book_path}")) &&
              anchor.gsub(/<[^>]+>/, ' ').gsub(/\s+/, ' ').include?('本を追加する')
          end

          expect(add_book_link).to be_present
          expect(add_book_link).not_to match(/\bdisabled\b/)
        end

        it '書籍一覧が表示される' do
          get books_path

          expect(response.body).to include(book_far.title)
          expect(response.body).to include(book_near.title)
          expect(response.body).to include(book_completed.title)
          expect(response.body).to include(book_completed_without_rating.title)
        end

        it '書影画像には読み込み失敗時フォールバックが設定される' do
          create(:book, user: user, title: '書影あり', cover_image_url: 'https://cover.openbd.jp/9784873115658.jpg')

          get books_path

          expect(response.body).to include('book-card__cover-image')
          expect(response.body).to include('onerror="this.onerror=null;this.style.display=')
          expect(response.body).to include('book-card__cover-placeholder" aria-hidden="true" style="display: none;"')
        end

        it '読了済みかつ評価ありの本に評価（★）が表示される' do
          get books_path

          doc = Nokogiri::HTML.parse(response.body)
          target_item = doc.css('.book-list__item').find do |item|
            item.at_css('.book-card__title')&.text&.strip == book_completed.title
          end

          expect(target_item).to be_present
          expect(target_item.at_css('.book-card__rating-stars')&.text&.strip).to eq('★★★★')
        end

        it '評価の境界値（1点/5点）でも星数が一致して表示される' do
          completed_rating_1 = create(:book, user: user, title: '評価1の読了本', status: :completed, rating: 1,
                                              deadline: Date.current + 9)
          completed_rating_5 = create(:book, user: user, title: '評価5の読了本', status: :completed, rating: 5,
                                              deadline: Date.current + 10)

          get books_path

          doc = Nokogiri::HTML.parse(response.body)
          rating_map = {
            completed_rating_1.title => '★',
            completed_rating_5.title => '★★★★★'
          }

          rating_map.each do |title, stars|
            target_item = doc.css('.book-list__item').find do |item|
              item.at_css('.book-card__title')&.text&.strip == title
            end

            expect(target_item).to be_present
            expect(target_item.at_css('.book-card__rating-stars')&.text&.strip).to eq(stars)
          end
        end

        it '読了済みでも評価未設定の本には評価（★）が表示されない' do
          get books_path

          doc = Nokogiri::HTML.parse(response.body)
          target_item = doc.css('.book-list__item').find do |item|
            item.at_css('.book-card__title')&.text&.strip == book_completed_without_rating.title
          end

          expect(target_item).to be_present
          expect(target_item.css('.book-card__rating-stars')).to be_empty
        end

        it '未読/読書中の本には評価（★）が表示されない' do
          get books_path

          doc = Nokogiri::HTML.parse(response.body)
          [ book_far.title, book_near.title ].each do |title|
            target_item = doc.css('.book-list__item').find do |item|
              item.at_css('.book-card__title')&.text&.strip == title
            end

            expect(target_item).to be_present
            expect(target_item.css('.book-card__rating-stars')).to be_empty
          end
        end

        it '未了本が期限の近い順に表示される（読了本より前に）' do
          get books_path

          body = response.body
          pos_near = body.index(book_near.title)
          pos_far = body.index(book_far.title)
          pos_completed = body.index(book_completed.title)

          expect(pos_near).to be < pos_far
          expect(pos_near).to be < pos_completed
          expect(pos_far).to be < pos_completed
        end

        it 'progress_percentage が表示される' do
          get books_path

          expect(response.body).to include('0%')
        end

        it '今日のノルマが未了本に表示される' do
          get books_path

          expect(response.body).to include('今日のノルマ')
        end

        it '今日のノルマが読了本には表示されない' do
          get books_path

          body = response.body

          # 今日のノルマは未了本(book_far, book_near)にのみ表示され、
          # 読了本(book_completed)の分は表示されないことを確認する
          expect(body.scan('book-card__quota-label').size).to eq(2)
        end

        it '期限超過の本には「期限超過」メッセージが表示される' do
          travel_to(10.days.ago) do
            create(:book, user: user, title: '期限超過の本', deadline: Date.current + 5, status: :unread)
          end
          get books_path

          expect(response.body).to include('期限超過')
        end

        it '自分の書籍だけが表示される' do
          other_book = create(:book, user: other_user, title: '他ユーザーの積読本')
          get books_path

          expect(response.body).to include(book_far.title)
          expect(response.body).not_to include(other_book.title)
        end

        context '読了済み本の日付表示' do
          it '読了済み本に「読了日」ラベルが表示される' do
            get books_path

            expect(response.body).to include('読了日')
          end

          it '読了済み本の completed_at の日付が表示される' do
            completed_date = Date.current - 3
            book_completed.update!(completed_at: completed_date.in_time_zone)
            get books_path

            expect(response.body).to include(I18n.l(completed_date, format: :long))
          end

          it '未読/読書中の本に「読了期限」ラベルが表示される' do
            get books_path

            expect(response.body).to include('読了期限')
          end
        end
      end

      context 'ログイン後のリダイレクト' do
        it 'ログインすると積読一覧にリダイレクトされる' do
          sign_out user
          password = 'password123'
          user.update!(password: password, password_confirmation: password)

          post user_session_path, params: {
            user: { email: user.email, password: password }
          }

          expect(response).to redirect_to(books_path)
        end
      end
    end
  end

  describe 'GET /books/new' do
    context '認証済みユーザーの場合' do
      before { sign_in user }

      it '200を返す' do
        get new_book_path
        expect(response).to have_http_status(:ok)
      end

      it '書籍登録フォームが表示される' do
        get new_book_path
        expect(response.body).to include('積読を登録する')
      end

      it 'ISBN入力フィールドが表示されない' do
        get new_book_path
        expect(response.body).not_to include('isbn_input')
        expect(response.body).not_to include('書籍情報を取得')
      end
    end

    context '未認証ユーザーの場合' do
      it 'ログインページへリダイレクトされる' do
        get new_book_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'POST /books' do
    context '認証済みユーザーの場合' do
      before { sign_in user }

      context '有効なパラメータの場合' do
        let(:valid_params) do
          {
            book: {
              title: 'リーダブルコード',
              author: 'Dustin Boswell',
              genre: 'プログラミング',
              total_pages: 260,
              target_pages: 260,
              current_page: 0,
              deadline: Date.current + 14
            }
          }
        end

        it '書籍が作成される' do
          expect {
            post books_path, params: valid_params
          }.to change(Book, :count).by(1)
        end

        it '書籍詳細画面にリダイレクトされる' do
          post books_path, params: valid_params
          expect(response).to redirect_to(book_path(Book.last))
        end

        it '現在のユーザーに紐付いた書籍が作成される' do
          post books_path, params: valid_params
          expect(Book.last.user).to eq(user)
        end

        it 'ジャンルが保存される' do
          post books_path, params: valid_params

          expect(Book.last.genre).to eq('プログラミング')
        end

        it '既に読んだページ数を指定した場合は進捗に反映される' do
          params_with_current_page = valid_params.deep_dup
          params_with_current_page[:book][:current_page] = 80

          post books_path, params: params_with_current_page

          created_book = Book.last
          expect(created_book.current_page).to eq(80)
          expect(created_book.progress_percentage).to eq(31)
        end

        it '既に読んだページ数が未入力の場合は0として保存される' do
          params_without_current_page = valid_params.deep_dup
          params_without_current_page[:book][:current_page] = ''

          post books_path, params: params_without_current_page

          expect(Book.last.current_page).to eq(0)
        end
      end

      context 'cover_image_urlを含む有効なパラメータの場合' do
        let(:params_with_cover) do
          {
            book: {
              title: '書影付きの本',
              total_pages: 200,
              target_pages: 200,
              current_page: 0,
              deadline: Date.current + 14,
              cover_image_url: 'https://cover.openbd.jp/9784873115658.jpg'
            }
          }
        end

        it '書籍がcover_image_urlつきで作成される' do
          post books_path, params: params_with_cover
          expect(Book.last.cover_image_url).to eq('https://cover.openbd.jp/9784873115658.jpg')
        end
      end

      context 'isbnを含む有効なパラメータの場合' do
        let(:params_with_isbn) do
          {
            book: {
              title: 'ISBNありの本',
              total_pages: 200,
              target_pages: 200,
              current_page: 0,
              deadline: Date.current + 14,
              isbn: '9784873115658'
            }
          }
        end

        it '書籍がisbnつきで作成される' do
          expect {
            post books_path, params: params_with_isbn
          }.to change(Book, :count).by(1)
          expect(Book.last.isbn).to eq('9784873115658')
        end
      end

      context '無効なcover_image_urlの場合' do
        let(:invalid_cover_params) do
          {
            book: {
              title: '不正URL書影の本',
              total_pages: 200,
              target_pages: 200,
              current_page: 0,
              deadline: Date.current + 14,
              cover_image_url: 'not-a-url'
            }
          }
        end

        it '書籍が作成されない' do
          expect {
            post books_path, params: invalid_cover_params
          }.not_to change(Book, :count)
        end

        it 'フォームを再表示する（422）' do
          post books_path, params: invalid_cover_params
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context '無効なパラメータ（タイトルなし）の場合' do
        let(:invalid_params) do
          {
            book: {
              title: '',
              total_pages: 260,
              target_pages: 260,
              current_page: 0,
              deadline: Date.current + 14
            }
          }
        end

        it '書籍が作成されない' do
          expect {
            post books_path, params: invalid_params
          }.not_to change(Book, :count)
        end

        it 'フォームを再表示する（422）' do
          post books_path, params: invalid_params
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context '無効なパラメータ（ジャンルが長すぎる）の場合' do
        let(:invalid_genre_params) do
          {
            book: {
              title: 'テスト本',
              genre: 'あ' * 101,
              total_pages: 260,
              target_pages: 260,
              current_page: 0,
              deadline: Date.current + 14
            }
          }
        end

        it '書籍が作成されない' do
          expect {
            post books_path, params: invalid_genre_params
          }.not_to change(Book, :count)
        end

        it 'フォームを再表示する（422）' do
          post books_path, params: invalid_genre_params

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context '無効なパラメータ（過去の期限）の場合' do
        let(:past_deadline_params) do
          {
            book: {
              title: 'テスト本',
              total_pages: 100,
              target_pages: 100,
              current_page: 0,
              deadline: Date.current - 1
            }
          }
        end

        it '書籍が作成されない' do
          expect {
            post books_path, params: past_deadline_params
          }.not_to change(Book, :count)
        end

        it 'フォームを再表示する（422）' do
          post books_path, params: past_deadline_params
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context '無効なパラメータ（現在ページが負数）の場合' do
        let(:invalid_current_page_params) do
          {
            book: {
              title: 'テスト本',
              total_pages: 300,
              target_pages: 250,
              current_page: -1,
              deadline: Date.current + 14
            }
          }
        end

        it '書籍が作成されない' do
          expect {
            post books_path, params: invalid_current_page_params
          }.not_to change(Book, :count)
        end

        it 'フォームを再表示する（422）' do
          post books_path, params: invalid_current_page_params
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'フォームに0以上エラーが表示される' do
          post books_path, params: invalid_current_page_params

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include('現在ページは0以上の値にしてください')
        end
      end

      context '無効なパラメータ（現在ページが読了対象ページ数を超過）の場合' do
        let(:over_target_params) do
          {
            book: {
              title: 'テスト本',
              total_pages: 300,
              target_pages: 250,
              current_page: 251,
              deadline: Date.current + 14
            }
          }
        end

        it '書籍が作成されない' do
          expect {
            post books_path, params: over_target_params
          }.not_to change(Book, :count)
        end

        it 'フォームに読了対象ページ数超過エラーが表示される' do
          post books_path, params: over_target_params

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include('現在ページは読了対象ページ数（250ページ）以下にしてください')
        end
      end

      context '無効なパラメータ（現在ページが総ページ数を超過）の場合' do
        let(:over_total_params) do
          {
            book: {
              title: 'テスト本',
              total_pages: 250,
              target_pages: 250,
              current_page: 251,
              deadline: Date.current + 14
            }
          }
        end

        it '書籍が作成されない' do
          expect {
            post books_path, params: over_total_params
          }.not_to change(Book, :count)
        end

        it 'フォームに総ページ数超過エラーが表示される' do
          post books_path, params: over_total_params

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include('現在ページは総ページ数（250ページ）以下にしてください')
        end
      end

      context '過去に読んだ本として登録（読了日あり）の場合' do
        let(:past_reading_with_date_params) do
          {
            book: {
              title: '過去に読んだ本',
              total_pages: 300,
              target_pages: 300,
              current_page: 0,
              deadline: Date.current + 14,
              is_past_reading: 'true',
              completed_at_input: (Date.current - 5).to_s
            }
          }
        end

        it '書籍が作成される' do
          expect {
            post books_path, params: past_reading_with_date_params
          }.to change(Book, :count).by(1)
        end

        it '書籍が completed ステータスで作成される' do
          post books_path, params: past_reading_with_date_params
          book = Book.last
          expect(book.status).to eq('completed')
        end

        it '現在ページが target_pages で設定される' do
          post books_path, params: past_reading_with_date_params
          book = Book.last
          expect(book.current_page).to eq(300)
        end

        it 'completed_at が入力された日付で設定される' do
          post books_path, params: past_reading_with_date_params
          book = Book.last
          expected_date = Date.current - 5
          expect(book.completed_at.to_date).to eq(expected_date)
        end

        it '書籍詳細画面にリダイレクトされる' do
          post books_path, params: past_reading_with_date_params
          expect(response).to redirect_to(book_path(Book.last))
        end
      end

      context '過去に読んだ本として登録（読了日なし）の場合' do
        let(:past_reading_without_date_params) do
          {
            book: {
              title: '過去に読んだ本（日付なし）',
              total_pages: 200,
              target_pages: 200,
              current_page: 0,
              deadline: Date.current + 14,
              is_past_reading: 'true',
              completed_at_input: ''
            }
          }
        end

        it '書籍が作成される' do
          expect {
            post books_path, params: past_reading_without_date_params
          }.to change(Book, :count).by(1)
        end

        it '書籍が completed ステータスで作成される' do
          post books_path, params: past_reading_without_date_params
          book = Book.last
          expect(book.status).to eq('completed')
        end

        it '現在ページが target_pages で設定される' do
          post books_path, params: past_reading_without_date_params
          book = Book.last
          expect(book.current_page).to eq(200)
        end

        it 'completed_at が現在時刻で設定される' do
          post books_path, params: past_reading_without_date_params
          book = Book.last
          # completed_at が Time.current で設定されているかを確認
          # 時刻が異なる可能性があるため、日付で確認
          expect(book.completed_at.to_date).to eq(Date.current)
        end
      end

      context '過去に読んだ本として登録（不正な日付フォーマット）の場合' do
        let(:invalid_date_format_params) do
          {
            book: {
              title: '不正な日付の本',
              total_pages: 250,
              target_pages: 250,
              current_page: 0,
              deadline: Date.current + 14,
              is_past_reading: 'true',
              completed_at_input: 'invalid-date'
            }
          }
        end

        it '書籍が作成されない' do
          expect {
            post books_path, params: invalid_date_format_params
          }.not_to change(Book, :count)
        end

        it 'フォームを再表示する（422）' do
          post books_path, params: invalid_date_format_params
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context '過去に読んだ本として登録（未来日）の場合' do
        let(:future_date_params) do
          {
            book: {
              title: '未来日の本',
              total_pages: 250,
              target_pages: 250,
              current_page: 0,
              deadline: Date.current + 14,
              is_past_reading: 'true',
              completed_at_input: (Date.current + 5).to_s
            }
          }
        end

        it '書籍が作成されない' do
          expect {
            post books_path, params: future_date_params
          }.not_to change(Book, :count)
        end

        it 'フォームを再表示する（422）' do
          post books_path, params: future_date_params
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context '未認証ユーザーの場合' do
      it 'ログインページへリダイレクトされる' do
        post books_path, params: { book: { title: 'テスト' } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET /books/:id' do
    context '認証済みユーザーの場合' do
      before { sign_in user }

      it '自分の書籍は表示できる' do
        book = create(:book, user: user)
        get book_path(book)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(book.title)
      end

      it 'cover_image_urlがある場合は<img>タグで表示される' do
        book = create(:book, user: user, cover_image_url: 'https://cover.openbd.jp/9784873115658.jpg')
        get book_path(book)
        expect(response.body).to include('https://cover.openbd.jp/9784873115658.jpg')
        expect(response.body).to include('<img')
      end

      it '書影画像には読み込み失敗時フォールバックが設定される' do
        book = create(:book, user: user, cover_image_url: 'https://cover.openbd.jp/9784873115658.jpg')

        get book_path(book)

        expect(response.body).to include('book-show__cover-image')
        expect(response.body).to include('onerror="this.onerror=null;this.style.display=')
        expect(response.body).to include('book-show__cover-placeholder" aria-hidden="true" style="display: none;"')
      end

      it 'cover_image_urlがない場合はプレースホルダーが表示される' do
        book = create(:book, user: user, cover_image_url: nil)
        get book_path(book)
        expect(response.body).to include('book-show__cover-placeholder')
      end

      it '他ユーザーの書籍は表示できない（404）' do
        other_book = create(:book, user: other_user)
        get book_path(other_book)
        expect(response).to have_http_status(:not_found)
      end

      it '今日のノルマが表示される（未了本）' do
        book = create(:book, user: user, current_page: 0, target_pages: 100,
                             deadline: Date.current + 9, status: :unread)
        get book_path(book)
        expect(response.body).to include('今日のノルマ')
        # <strong>10</strong> ページ として描画されるため数値と単位を個別に確認
        expect(response.body).to include('>10<')
        expect(response.body).to include('ページ')
      end

      it '読了済みの場合はノルマ欄に「読了済み」が表示される' do
        book = create(:book, user: user, status: :completed, current_page: 100,
                             target_pages: 100, deadline: Date.current + 5)
        get book_path(book)
        expect(response.body).to include('読了済み')
      end

      it '期限超過の場合はノルマ欄に「期限超過」が表示される' do
        overdue_book = travel_to(10.days.ago) do
          create(:book, user: user, deadline: Date.current + 5, status: :unread,
                        current_page: 0, target_pages: 100)
        end
        get book_path(overdue_book)
        expect(response.body).to include('期限超過')
      end

      it '詳細画面に残りページ数が表示される' do
        book = create(:book, user: user, current_page: 50, target_pages: 200,
                             deadline: Date.current + 5)
        get book_path(book)
        expect(response.body).to include('150 ページ')
      end

      it 'ステータスバッジが表示される' do
        book = create(:book, user: user, status: :reading)
        get book_path(book)
        expect(response.body).to include('book-show__status--reading')
        expect(response.body).to include('読書中')
      end

      it '進捗プログレスバーが表示される' do
        book = create(:book, user: user, current_page: 50, target_pages: 100)
        get book_path(book)
        expect(response.body).to include('book-show__progress-bar')
      end

      it '読書進捗グラフが表示される（ログあり）' do
        travel_to(Date.new(2026, 5, 12)) do
          book = create(:book, user: user)
          create(:reading_log, book: book, read_at: Date.new(2026, 5, 10), pages_read: 20)

          get book_path(book)

          expect(response.body).to include('読書進捗グラフ')
          expect(response.body).to include('横軸: 日付 / 縦軸: ページ数')
          expect(response.body).to include('book-show__chart-line')
          expect(response.body).to include('data-date="2026-05-10"')
          expect(response.body).to include('data-pages="20"')
        end
      end

      it '表示期間の開始日は初回読書ログ日になる（作成日では始まらない）' do
        travel_to(Date.new(2026, 5, 20)) do
          book = create(:book, user: user)
          book.update_column(:created_at, Time.zone.parse('2026-05-10 09:00:00'))
          create(:reading_log, book: book, read_at: Date.new(2026, 5, 15), pages_read: 7)

          get book_path(book)

          expect(response.body).to include('data-date="2026-05-15"')
          expect(response.body).not_to include('data-date="2026-05-10"')
        end
      end

      it '記録がない日は 0 ページとして表示される' do
        travel_to(Date.new(2026, 5, 12)) do
          book = create(:book, user: user)
          create(:reading_log, book: book, read_at: Date.new(2026, 5, 10), pages_read: 12)

          get book_path(book)

          expect(response.body).to include('data-date="2026-05-11"')
          expect(response.body).to include('data-pages="0"')
        end
      end

      it '読了済み本は読了日までをグラフ表示期間にする' do
        travel_to(Date.new(2026, 5, 20)) do
          book = create(:book, user: user, status: :completed, completed_at: Time.zone.parse('2026-05-14 10:00:00'))
          create(:reading_log, book: book, read_at: Date.new(2026, 5, 13), pages_read: 18)
          create(:reading_log, book: book, read_at: Date.new(2026, 5, 16), pages_read: 9)

          get book_path(book)

          expect(response.body).to include('data-date="2026-05-14"')
          expect(response.body).not_to include('data-date="2026-05-16"')
        end
      end

      it '読書ログがない場合は空状態メッセージを表示する' do
        book = create(:book, user: user)

        get book_path(book)

        expect(response.body).to include('読書ログがまだありません。進捗を記録するとグラフが表示されます。')
      end

      it '延長回数が表示される' do
        book = create(:book, user: user, extension_count: 2)
        get book_path(book)
        expect(response.body).to include('延長回数')
        expect(response.body).to include('2')
      end

      it '「一覧に戻る」ボタンが表示される' do
        book = create(:book, user: user)
        get book_path(book)
        expect(response.body).to include('一覧に戻る')
        expect(response.body).to include(books_path)
      end

      it '残り7日以下の本に urgent-low クラスが表示される' do
        book = create(:book, user: user, deadline: Date.current + 6)
        get book_path(book)
        expect(response.body).to include('book-card__cover--urgent-low')
        expect(response.body).to include('あと7日')
      end

      it '残り3日以下の本に urgent-medium クラスが表示される' do
        book = create(:book, user: user, deadline: Date.current + 2)
        get book_path(book)
        expect(response.body).to include('book-card__cover--urgent-medium')
        expect(response.body).to include('あと3日')
      end

      it '残り1日（期限当日）の本に urgent-high クラスと「期限間近！」バッジが表示される' do
        book = create(:book, user: user, deadline: Date.current)
        get book_path(book)
        expect(response.body).to include('book-card__cover--urgent-high')
        expect(response.body).to include('期限間近！')
      end

      it '読了済みの場合は urgency クラスが表示されない' do
        book = create(:book, user: user, status: :completed, current_page: 300,
                             target_pages: 300, deadline: Date.current)
        get book_path(book)
        expect(response.body).not_to include('book-card__cover--urgent-high')
        expect(response.body).not_to include('book-show__urgency-badge')
      end

      it '残り8日以上の本は urgency クラスが表示されない' do
        book = create(:book, user: user, deadline: Date.current + 7)
        get book_path(book)
        expect(response.body).not_to include('book-card__cover--urgent')
      end

      it 'Googleカレンダー連携セクションが表示される' do
        book = create(:book, user: user, title: 'テスト書籍')
        get book_path(book)
        expect(response.body).to include('data-controller="google-calendar"')
        expect(response.body).to include('Googleカレンダーで予定を作る')
        expect(response.body).to include('value="30"')
        expect(response.body).to include('checked')
        expect(response.body).to include('MVPでは、Google側での予定の変更・削除はアプリ内に反映されません')
        expect(response.body).to include('data-google-calendar-title-value="【Yomikiri】テスト書籍"')
        expect(response.body).to include('data-google-calendar-description-value="【Yomikiri】「テスト書籍」の読書時間"')
      end
    end

    context '未認証ユーザーの場合' do
      it 'ログインページへリダイレクトされる' do
        book = create(:book, user: user)
        get book_path(book)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'DELETE /books/:id' do
    context '認証済みユーザーの場合' do
      before { sign_in user }

      it '自分の書籍を削除できる' do
        book = create(:book, user: user)
        expect {
          delete book_path(book)
        }.to change(Book, :count).by(-1)
      end

      it '削除後、積読一覧画面へリダイレクトされる' do
        book = create(:book, user: user)
        delete book_path(book)
        expect(response).to redirect_to(books_path)
      end

      it '他ユーザーの書籍は削除できない（404）' do
        other_book = create(:book, user: other_user)
        expect {
          delete book_path(other_book)
        }.not_to change(Book, :count)
        expect(response).to have_http_status(:not_found)
      end
    end

    context '未認証ユーザーの場合' do
      it 'ログインページへリダイレクトされる' do
        book = create(:book, user: user)
        delete book_path(book)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET /books/:id/edit' do
    context '認証済みユーザーの場合' do
      before { sign_in user }

      it '自分の書籍の編集画面を表示できる' do
        book = create(:book, user: user)
        get edit_book_path(book)
        expect(response).to have_http_status(:ok)
      end

      it '編集画面にISBN入力UIが表示されない' do
        book = create(:book, user: user)
        get edit_book_path(book)

        expect(response.body).not_to include('isbn_input')
        expect(response.body).not_to include('書籍情報を取得')
      end

      it '他ユーザーの書籍の編集画面は404になる' do
        other_book = create(:book, user: other_user)
        get edit_book_path(other_book)
        expect(response).to have_http_status(:not_found)
      end
    end

    context '未認証ユーザーの場合' do
      it 'ログインページへリダイレクトされる' do
        book = create(:book, user: user)
        get edit_book_path(book)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'PATCH /books/:id' do
    context '認証済みユーザーの場合' do
      before { sign_in user }

      context '有効なパラメータの場合' do
        it '書籍情報が更新される' do
          book = create(:book, user: user, title: '旧タイトル', author: '旧著者')
          patch book_path(book), params: { book: { title: '新タイトル', author: '新著者', genre: book.genre, total_pages: book.total_pages, target_pages: book.target_pages, deadline: book.deadline } }
          expect(book.reload.title).to eq('新タイトル')
          expect(book.reload.author).to eq('新著者')
        end

        it '更新後、書籍詳細画面へリダイレクトされる' do
          book = create(:book, user: user)
          patch book_path(book), params: { book: { title: book.title, author: book.author, genre: book.genre, total_pages: book.total_pages, target_pages: book.target_pages, deadline: book.deadline } }
          expect(response).to redirect_to(book_path(book))
        end

        it 'フラッシュメッセージが表示される' do
          book = create(:book, user: user)
          patch book_path(book), params: { book: { title: book.title, author: book.author, genre: book.genre, total_pages: book.total_pages, target_pages: book.target_pages, deadline: book.deadline } }
          follow_redirect!
          expect(response.body).to include('情報を更新しました。')
        end
      end

      context '無効なパラメータ（タイトルなし）の場合' do
        it '422 Unprocessable Entity を返す' do
          book = create(:book, user: user)
          patch book_path(book), params: { book: { title: '', total_pages: book.total_pages, target_pages: book.target_pages, deadline: book.deadline } }
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it '書籍情報は更新されない' do
          book = create(:book, user: user, title: '元のタイトル')
          patch book_path(book), params: { book: { title: '', total_pages: book.total_pages, target_pages: book.target_pages, deadline: book.deadline } }
          expect(book.reload.title).to eq('元のタイトル')
        end
      end

      context '読了済み書籍の場合' do
        it '過去日の読了期限に更新できる' do
          book = create(:book, user: user, status: :completed, deadline: Date.current + 1)
          past_deadline = Date.current - 10
          patch book_path(book), params: { book: { title: book.title, author: book.author, genre: book.genre, total_pages: book.total_pages, target_pages: book.target_pages, deadline: past_deadline } }
          expect(response).to redirect_to(book_path(book))
          expect(book.reload.deadline).to eq(past_deadline)
        end
      end

      it '他ユーザーの書籍は更新できない（404）' do
        other_book = create(:book, user: other_user)
        patch book_path(other_book), params: { book: { title: '改ざん' } }
        expect(response).to have_http_status(:not_found)
      end
    end

    context '未認証ユーザーの場合' do
      it 'ログインページへリダイレクトされる' do
        book = create(:book, user: user)
        patch book_path(book), params: { book: { title: book.title } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'PATCH /books/:id/update_progress' do
    context '認証済みユーザーの場合' do
      before { sign_in user }

      context '今日読んだページ数（pages_read）で更新する場合' do
        it 'current_page が pages_read 分加算される' do
          book = create(:book, user: user, current_page: 10, target_pages: 100)
          patch update_progress_book_path(book), params: { pages_read: 20 }
          expect(book.reload.current_page).to eq(30)
        end

        it '読書ログが記録される' do
          book = create(:book, user: user, current_page: 10, target_pages: 100)

          expect do
            patch update_progress_book_path(book), params: { pages_read: 20 }
          end.to change(ReadingLog, :count).by(1)

          log = ReadingLog.last
          expect(log.book).to eq(book)
          expect(log.pages_read).to eq(20)
          expect(log.read_at).to eq(Date.current)
          expect(log.start_page).to eq(11)
          expect(log.end_page).to eq(30)
        end

        it '更新後、書籍詳細画面へリダイレクトされる' do
          book = create(:book, user: user, current_page: 0, target_pages: 100)
          patch update_progress_book_path(book), params: { pages_read: 10 }
          expect(response).to redirect_to(book_path(book))
        end

        it 'フラッシュメッセージが表示される' do
          book = create(:book, user: user, current_page: 0, target_pages: 100)
          patch update_progress_book_path(book), params: { pages_read: 10 }
          follow_redirect!
          expect(response.body).to include('進捗を更新しました。')
        end

        it 'current_page が target_pages を超える場合はバリデーションエラーになる' do
          book = create(:book, user: user, current_page: 90, target_pages: 100)
          patch update_progress_book_path(book), params: { pages_read: 20 }
          expect(response).to have_http_status(:unprocessable_entity)
          expect(book.reload.current_page).to eq(90)
        end

        it 'pages_read が負の値の場合はバリデーションエラーになり current_page が変わらない' do
          book = create(:book, user: user, current_page: 50, target_pages: 100)
          patch update_progress_book_path(book), params: { pages_read: -1 }
          expect(response).to have_http_status(:unprocessable_entity)
          expect(book.reload.current_page).to eq(50)
        end

        it 'pages_read が非数値の場合はバリデーションエラーになり current_page が変わらない' do
          book = create(:book, user: user, current_page: 50, target_pages: 100)
          patch update_progress_book_path(book), params: { pages_read: 'abc' }
          expect(response).to have_http_status(:unprocessable_entity)
          expect(book.reload.current_page).to eq(50)
        end

        it 'pages_read が 0 の場合はバリデーションエラーになり current_page が変わらない' do
          book = create(:book, user: user, current_page: 50, target_pages: 100)
          patch update_progress_book_path(book), params: { pages_read: 0 }
          expect(response).to have_http_status(:unprocessable_entity)
          expect(book.reload.current_page).to eq(50)
        end
      end

      context '現在ページを直接入力（direct_page）で更新する場合' do
        it 'current_page が指定した値に更新される' do
          book = create(:book, user: user, current_page: 10, target_pages: 200)
          patch update_progress_book_path(book), params: { direct_page: 50 }
          expect(book.reload.current_page).to eq(50)
        end

        it '増分がある場合は読書ログが記録される' do
          book = create(:book, user: user, current_page: 10, target_pages: 200)

          expect do
            patch update_progress_book_path(book), params: { direct_page: 50 }
          end.to change(ReadingLog, :count).by(1)

          expect(ReadingLog.last.pages_read).to eq(40)
        end

        it 'direct_page と pages_read が同時に送信されても増分で読書ログを記録する' do
          book = create(:book, user: user, current_page: 10, target_pages: 200)

          patch update_progress_book_path(book), params: { direct_page: 50, pages_read: 5 }

          expect(book.reload.current_page).to eq(50)
          expect(ReadingLog.last.pages_read).to eq(40)
        end

        it '増分がない場合は読書ログを記録しない' do
          book = create(:book, user: user, current_page: 10, target_pages: 200)

          expect do
            patch update_progress_book_path(book), params: { direct_page: 10 }
          end.not_to change(ReadingLog, :count)
        end

        it 'direct_page が target_pages を超える場合はバリデーションエラーになる' do
          book = create(:book, user: user, current_page: 10, target_pages: 100)
          patch update_progress_book_path(book), params: { direct_page: 150 }
          expect(response).to have_http_status(:unprocessable_entity)
          expect(book.reload.current_page).to eq(10)
        end
      end

      it '他ユーザーの書籍は更新できない（404）' do
        other_book = create(:book, user: other_user, current_page: 0, target_pages: 100)
        patch update_progress_book_path(other_book), params: { pages_read: 10 }
        expect(response).to have_http_status(:not_found)
        expect(other_book.reload.current_page).to eq(0)
      end
    end

    context '未認証ユーザーの場合' do
      it 'ログインページへリダイレクトされる' do
        book = create(:book, user: user, current_page: 0, target_pages: 100)
        patch update_progress_book_path(book), params: { pages_read: 10 }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'PATCH /books/:id/change_deadline' do
    context '認証済みユーザーの場合' do
      before { sign_in user }

      it 'deadlineが更新される' do
        book = create(:book, user: user, deadline: Date.current + 7)
        new_deadline = Date.current + 14
        patch change_deadline_book_path(book), params: { deadline: new_deadline.to_s }
        expect(book.reload.deadline).to eq(new_deadline)
      end

      it 'extension_countがインクリメントされる' do
        book = create(:book, user: user, deadline: Date.current + 7, extension_count: 1)
        patch change_deadline_book_path(book), params: { deadline: (Date.current + 14).to_s }
        expect(book.reload.extension_count).to eq(2)
      end

      it '更新後、書籍詳細画面にリダイレクトされる' do
        book = create(:book, user: user, deadline: Date.current + 7)
        patch change_deadline_book_path(book), params: { deadline: (Date.current + 14).to_s }
        expect(response).to redirect_to(book_path(book))
      end

      it 'フラッシュメッセージが表示される' do
        book = create(:book, user: user, deadline: Date.current + 7)
        patch change_deadline_book_path(book), params: { deadline: (Date.current + 14).to_s }
        follow_redirect!
        expect(response.body).to include('読了期限を延長しました。')
      end

      it '現在の期限と同じ日付は無効（422）' do
        book = create(:book, user: user, deadline: Date.current + 7)
        patch change_deadline_book_path(book), params: { deadline: (Date.current + 7).to_s }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(book.reload.deadline).to eq(Date.current + 7)
      end

      it '現在の期限より前の日付は無効（422）' do
        book = create(:book, user: user, deadline: Date.current + 7)
        patch change_deadline_book_path(book), params: { deadline: (Date.current + 3).to_s }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(book.reload.deadline).to eq(Date.current + 7)
      end

      it '日付として不正な文字列は無効（422）' do
        book = create(:book, user: user, deadline: Date.current + 7)
        patch change_deadline_book_path(book), params: { deadline: 'not-a-date' }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(book.reload.deadline).to eq(Date.current + 7)
      end

      it '他ユーザーの書籍は更新できない（404）' do
        other_book = create(:book, user: other_user, deadline: Date.current + 7)
        patch change_deadline_book_path(other_book), params: { deadline: (Date.current + 14).to_s }
        expect(response).to have_http_status(:not_found)
        expect(other_book.reload.deadline).to eq(Date.current + 7)
      end
    end

    context '未認証ユーザーの場合' do
      it 'ログインページへリダイレクトされる' do
        book = create(:book, user: user, deadline: Date.current + 7)
        patch change_deadline_book_path(book), params: { deadline: (Date.current + 14).to_s }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'PATCH /books/:id/complete' do
    context '認証済みユーザーの場合' do
      before { sign_in user }

      context '正常な読了処理' do
        let!(:book) { create(:book, user: user, current_page: 100, target_pages: 100, status: :reading) }

        it 'status が completed になる' do
          patch complete_book_path(book)
          expect(book.reload.status).to eq('completed')
        end

        it 'completed_at が設定される' do
          freeze_time do
            patch complete_book_path(book)
            expect(book.reload.completed_at).to be_within(1.second).of(Time.current)
          end
        end

        it 'current_page が target_pages に揃えられる' do
          reading_book = create(:book, user: user, current_page: 80, target_pages: 100, status: :reading)
          patch complete_book_path(reading_book)
          expect(reading_book.reload.current_page).to eq(100)
        end

        it '未記録ページ分のReadingLogが作成される' do
          reading_book = create(:book, user: user, current_page: 80, target_pages: 100, status: :reading)

          expect {
            patch complete_book_path(reading_book)
          }.to change(ReadingLog, :count).by(1)

          reading_log = reading_book.reading_logs.order(:created_at).last
          expect(reading_log.pages_read).to eq(20)
          expect(reading_log.start_page).to eq(81)
          expect(reading_log.end_page).to eq(100)
          expect(reading_log.read_at).to eq(Date.current)
        end

        it '差分が0の場合はReadingLogを作成しない' do
          expect {
            patch complete_book_path(book)
          }.not_to change(ReadingLog, :count)
        end

        it 'ReadingLogの作成に失敗した場合は読了更新をロールバックする' do
          reading_book = create(:book, user: user, current_page: 80, target_pages: 100, status: :reading, completed_at: nil)
          allow_any_instance_of(BooksController).to receive(:create_reading_log_for_completion!).and_raise(
            ActiveRecord::RecordInvalid.new(ReadingLog.new)
          )

          patch complete_book_path(reading_book)

          expect(response).to have_http_status(:unprocessable_entity)
          reading_book.reload
          expect(reading_book.status).to eq('reading')
          expect(reading_book.current_page).to eq(80)
          expect(reading_book.completed_at).to be_nil
        end

        it '書籍詳細画面へリダイレクトされる' do
          patch complete_book_path(book)
          expect(response).to redirect_to(book_path(book))
        end

        it 'リダイレクト後の詳細画面で読了お祝いモーダルが表示される' do
          patch complete_book_path(book)
          follow_redirect!
          expect(response.body).to include('読了おめでとうございます')
          expect(response.body).to include(book.title)
        end

        it 'リダイレクト後の詳細画面に「一覧に戻る」ボタンが表示される' do
          patch complete_book_path(book)
          follow_redirect!
          expect(response.body).to include('一覧に戻る')
          expect(response.body).to include(books_path)
        end
      end

      context '冪等性: 既に読了済みの書籍を再度読了にする場合' do
        it 'completed_at が上書きされない' do
          original_time = 3.days.ago
          already_done = create(:book, user: user, status: :completed,
                                       current_page: 100, target_pages: 100,
                                       completed_at: original_time)
          patch complete_book_path(already_done)
          expect(already_done.reload.completed_at).to be_within(1.second).of(original_time)
        end
      end

      it '他ユーザーの書籍は読了にできない（404）' do
        other_book = create(:book, user: other_user, current_page: 100, target_pages: 100, deadline: Date.current + 7)
        patch complete_book_path(other_book)
        expect(response).to have_http_status(:not_found)
        expect(other_book.reload.status).to eq('reading')
      end
    end

    context '未認証ユーザーの場合' do
      it 'ログインページへリダイレクトされる' do
        book = create(:book, user: user, current_page: 100, target_pages: 100)
        patch complete_book_path(book)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'PATCH /books/:id/update_memo' do
    let!(:book) { create(:book, user: user, memo: '初期メモ') }

    context '認証済みユーザーの場合' do
      before { sign_in user }

      it 'メモを更新できる' do
        patch update_memo_book_path(book), params: { book: { memo: "気づきメモ\n次回の課題" } }

        expect(response).to redirect_to(book_path(book))
        expect(book.reload.memo).to eq("気づきメモ\n次回の課題")
      end

      it '空文字で保存するとメモをクリアできる' do
        patch update_memo_book_path(book), params: { book: { memo: '' } }

        expect(response).to redirect_to(book_path(book))
        expect(book.reload.memo).to eq('')
      end

      it '2000文字超過は422になる' do
        patch update_memo_book_path(book), params: { book: { memo: 'a' * 2001 } }

        expect(response).to have_http_status(422)
        expect(book.reload.memo).to eq('初期メモ')
      end

      it '表示時にHTMLタグがエスケープされる' do
        patch update_memo_book_path(book), params: { book: { memo: '<script>alert(1)</script>' } }
        follow_redirect!

        expect(response.body).not_to include('<script>alert(1)</script>')
      end

      it '改行を含むメモがDBに正しく保存される' do
        patch update_memo_book_path(book), params: { book: { memo: "1行目\n2行目" } }

        expect(response).to redirect_to(book_path(book))
        expect(book.reload.memo).to include("1行目")
        expect(book.reload.memo).to include("2行目")
      end

      it 'メモを更新するとmemo_updated_atが更新される' do
        freeze_time do
          patch update_memo_book_path(book), params: { book: { memo: '新しいメモ' } }

          expect(book.reload.memo_updated_at).to eq(Time.current)
        end
      end

      it 'メモ保存後のリダイレクト先でメモ入力フォームが表示される' do
        patch update_memo_book_path(book), params: { book: { memo: '保存するメモ' } }
        follow_redirect!

        expect(response.body).to include('name="book_memo[content]"')
      end

      it 'メモ保存後のリダイレクト先でメモタイムラインが表示される' do
        patch update_memo_book_path(book), params: { book: { memo: '日時確認メモ' } }
        follow_redirect!

        expect(response.body).to include('memo-timeline')
      end
    end

    context '未認証ユーザーの場合' do
      it 'ログインページへリダイレクトされる' do
        patch update_memo_book_path(book), params: { book: { memo: 'メモ' } }

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context '他ユーザーの書籍を更新する場合' do
      before { sign_in user }

      it '404を返す' do
        other_book = create(:book, user: other_user, memo: '他人のメモ')

        patch update_memo_book_path(other_book), params: { book: { memo: '更新不可' } }

        expect(response).to have_http_status(:not_found)
        expect(other_book.reload.memo).to eq('他人のメモ')
      end
    end
  end

  describe 'PATCH /books/:id/update_review' do
    let!(:book) { create(:book, user: user, status: :completed, current_page: 100, target_pages: 100) }

    context '認証済みユーザーの場合' do
      before { sign_in user }

      it '評価と感想を保存できる' do
        patch update_review_book_path(book), params: { book: { rating: 4, review: '面白かった' } }

        expect(response).to redirect_to(books_path)
        expect(book.reload.rating).to eq(4)
        expect(book.reload.review).to eq('面白かった')
      end

      it '評価のみ保存できる' do
        patch update_review_book_path(book), params: { book: { rating: 5 } }

        expect(response).to redirect_to(books_path)
        expect(book.reload.rating).to eq(5)
      end

      it '感想のみ保存できる' do
        patch update_review_book_path(book), params: { book: { review: '良い本でした' } }

        expect(response).to redirect_to(books_path)
        expect(book.reload.review).to eq('良い本でした')
      end

      it 'ratingが6の場合は422になる' do
        patch update_review_book_path(book), params: { book: { rating: 6 } }

        expect(response).to have_http_status(422)
      end

      it '感想が1001文字以上の場合は422になる' do
        patch update_review_book_path(book), params: { book: { review: 'a' * 1001 } }

        expect(response).to have_http_status(422)
      end

      it '感想表示時にHTMLタグがエスケープされる' do
        patch update_review_book_path(book), params: { book: { review: '<script>alert(1)</script>' } }
        get book_path(book)

        expect(response.body).to include('&lt;script&gt;alert(1)&lt;/script&gt;')
        expect(response.body).not_to include('<script>alert(1)</script>')
      end

      it 'フラッシュメッセージが表示される' do
        patch update_review_book_path(book), params: { book: { rating: 4, review: '良い本' } }
        follow_redirect!

        expect(response.body).to include('評価・感想を保存しました。')
      end
    end

    context '未認証ユーザーの場合' do
      it 'ログインページへリダイレクトされる' do
        patch update_review_book_path(book), params: { book: { rating: 3 } }

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context '他ユーザーの書籍を更新する場合' do
      before { sign_in user }

      it '404を返す' do
        other_book = create(:book, user: other_user, status: :completed, current_page: 100, target_pages: 100)

        patch update_review_book_path(other_book), params: { book: { rating: 5 } }

        expect(response).to have_http_status(:not_found)
        expect(other_book.reload.rating).to be_nil
      end
    end
  end

  describe 'GET /books/search' do
    context '未認証ユーザーの場合' do
      it 'ログインページへリダイレクトされる' do
        get search_books_path, params: { q: 'Ruby' }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context '認証済みユーザーの場合' do
      before { sign_in user }

      context 'クエリが空の場合' do
        it '空の書籍リストを返す' do
          get search_books_path, params: { q: '' }
          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          expect(json['books']).to eq([])
        end
      end

      context 'タイトル検索の場合' do
        let(:google_books_data) do
          {
            'items' => [
              {
                'volumeInfo' => {
                  'title' => 'Rubyプログラミング入門',
                  'authors' => [ '著者名' ],
                  'categories' => [ 'プログラミング' ],
                  'pageCount' => 300,
                  'industryIdentifiers' => [
                    { 'type' => 'ISBN_13', 'identifier' => '9784000000001' }
                  ],
                  'imageLinks' => {
                    'thumbnail' => 'http://books.google.com/thumbnail.jpg',
                    'small' => 'https://books.google.com/small.jpg',
                    'medium' => 'https://books.google.com/medium.jpg',
                    'large' => 'https://books.google.com/large.jpg'
                  }
                }
              }
            ]
          }
        end

        before do
          allow_any_instance_of(BooksController).to receive(:fetch_title_json).and_return(google_books_data)
          allow_any_instance_of(BooksController).to receive(:lookup_openbd_book).and_return(nil)
          allow_any_instance_of(BooksController).to receive(:lookup_rakuten_cover_url).and_return('')
        end

        it '200 OK を返す' do
          get search_books_path, params: { q: 'Ruby' }
          expect(response).to have_http_status(:ok)
        end

        it '利用可能な最大サイズの書影URLを返す（large優先）' do
          get search_books_path, params: { q: 'Ruby' }
          json = JSON.parse(response.body)
          expect(json['books'].first['cover_image_url']).to eq('https://books.google.com/large.jpg')
        end

        it 'カテゴリがある場合はジャンルを返す' do
          get search_books_path, params: { q: 'Ruby' }
          json = JSON.parse(response.body)

          expect(json['books'].first['genre']).to eq('プログラミング')
        end
      end

      context 'タイトル検索でlargeがなくmediumがある場合' do
        let(:google_books_data) do
          {
            'items' => [
              {
                'volumeInfo' => {
                  'title' => 'Rubyプログラミング入門',
                  'authors' => [ '著者名' ],
                  'pageCount' => 300,
                  'industryIdentifiers' => [],
                  'imageLinks' => {
                    'thumbnail' => 'http://books.google.com/thumbnail.jpg',
                    'medium' => 'https://books.google.com/medium.jpg'
                  }
                }
              }
            ]
          }
        end

        before do
          allow_any_instance_of(BooksController).to receive(:fetch_title_json).and_return(google_books_data)
          allow_any_instance_of(BooksController).to receive(:lookup_openbd_book).and_return(nil)
          allow_any_instance_of(BooksController).to receive(:lookup_rakuten_cover_url).and_return('')
        end

        it 'mediumサイズの書影URLを返す' do
          get search_books_path, params: { q: 'Ruby' }
          json = JSON.parse(response.body)
          expect(json['books'].first['cover_image_url']).to eq('https://books.google.com/medium.jpg')
        end
      end

      context 'タイトル検索でimageLinksにthumbnailのみある場合' do
        let(:google_books_data) do
          {
            'items' => [
              {
                'volumeInfo' => {
                  'title' => 'Rubyプログラミング入門',
                  'authors' => [ '著者名' ],
                  'pageCount' => 300,
                  'industryIdentifiers' => [],
                  'imageLinks' => {
                    'thumbnail' => 'http://books.google.com/thumbnail.jpg'
                  }
                }
              }
            ]
          }
        end

        before do
          allow_any_instance_of(BooksController).to receive(:fetch_title_json).and_return(google_books_data)
          allow_any_instance_of(BooksController).to receive(:lookup_openbd_book).and_return(nil)
          allow_any_instance_of(BooksController).to receive(:lookup_rakuten_cover_url).and_return('')
        end

        it 'thumbnailをhttpsに変換して返す' do
          get search_books_path, params: { q: 'Ruby' }
          json = JSON.parse(response.body)
          expect(json['books'].first['cover_image_url']).to eq('https://books.google.com/thumbnail.jpg')
        end
      end

      context 'Google BooksにカテゴリがなくopenBDにジャンルがある場合' do
        let(:google_books_data) do
          {
            'items' => [
              {
                'volumeInfo' => {
                  'title' => 'Rubyプログラミング入門',
                  'authors' => [ '著者名' ],
                  'pageCount' => 300,
                  'industryIdentifiers' => [
                    { 'type' => 'ISBN_13', 'identifier' => '9784000000001' }
                  ],
                  'imageLinks' => {
                    'thumbnail' => 'http://books.google.com/thumbnail.jpg'
                  }
                }
              }
            ]
          }
        end

        let(:openbd_book) do
          {
            'summary' => {
              'genre' => 'プログラミング',
              'cover' => 'https://cover.openbd.jp/9784000000001.jpg'
            }
          }
        end

        before do
          allow_any_instance_of(BooksController).to receive(:fetch_title_json).and_return(google_books_data)
          allow_any_instance_of(BooksController).to receive(:lookup_openbd_book).and_return(openbd_book)
          allow_any_instance_of(BooksController).to receive(:lookup_rakuten_cover_url).and_return('')
        end

        it 'openBDジャンルを返す' do
          get search_books_path, params: { q: 'Ruby' }
          json = JSON.parse(response.body)

          expect(json['books'].first['genre']).to eq('プログラミング')
        end
      end
    end
  end

  describe 'GET /books/suggestions' do
    context '未ログインの場合' do
      it 'ログイン画面へリダイレクトされる' do
        get suggestions_books_path, params: { field: 'author', q: 'Dustin' }

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'ログイン済みの場合' do
      before { sign_in user }

      let!(:book1) { create(:book, user: user, author: 'Dustin Boswell', genre: 'プログラミング') }
      let!(:book2) { create(:book, user: user, author: 'Dustin Powers', genre: 'プログラミング') }
      let!(:book3) { create(:book, user: user, author: 'Yamada Taro', genre: '自己啓発') }
      let!(:other_book) { create(:book, user: other_user, author: 'Other User Author', genre: 'ビジネス') }

      context 'field=author の場合' do
        it '著者名の候補を返す' do
          get suggestions_books_path, params: { field: 'author', q: 'Dustin' }

          json = JSON.parse(response.body)
          expect(response).to have_http_status(:ok)
          expect(json['suggestions']).to include('Dustin Boswell', 'Dustin Powers')
          expect(json['suggestions']).not_to include('Yamada Taro')
        end

        it '他ユーザーの著者名は返さない' do
          get suggestions_books_path, params: { field: 'author', q: 'Other' }

          json = JSON.parse(response.body)
          expect(json['suggestions']).to be_empty
        end

        it 'q が空でも結果を返す' do
          get suggestions_books_path, params: { field: 'author', q: '' }

          json = JSON.parse(response.body)
          expect(response).to have_http_status(:ok)
          expect(json['suggestions']).to be_an(Array)
        end
      end

      context 'field=genre の場合' do
        it 'ジャンルの候補を返す' do
          get suggestions_books_path, params: { field: 'genre', q: 'プログラミング' }

          json = JSON.parse(response.body)
          expect(response).to have_http_status(:ok)
          expect(json['suggestions']).to include('プログラミング')
          expect(json['suggestions']).not_to include('自己啓発')
        end
      end

      context '不正な field が指定された場合' do
        it '400 Bad Request を返す' do
          get suggestions_books_path, params: { field: 'title', q: 'test' }

          expect(response).to have_http_status(:bad_request)
        end
      end
    end
  end
end
