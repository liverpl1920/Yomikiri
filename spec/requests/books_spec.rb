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
      end

      context '書籍が複数ある場合' do
        let!(:book_far) { create(:book, user: user, title: '遠い期限の本', deadline: Date.current + 30, status: :unread) }
        let!(:book_near) { create(:book, user: user, title: '近い期限の本', deadline: Date.current + 3, status: :reading) }
        let!(:book_completed) { create(:book, user: user, title: '読了済みの本', deadline: Date.current + 5, status: :completed) }

        it '200 OK を返す' do
          get books_path

          expect(response).to have_http_status(:ok)
        end

        it '書籍一覧が表示される' do
          get books_path

          expect(response.body).to include(book_far.title)
          expect(response.body).to include(book_near.title)
          expect(response.body).to include(book_completed.title)
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

  describe 'PATCH /books/:id/update_progress' do
    context '認証済みユーザーの場合' do
      before { sign_in user }

      context '今日読んだページ数（pages_read）で更新する場合' do
        it 'current_page が pages_read 分加算される' do
          book = create(:book, user: user, current_page: 10, target_pages: 100)
          patch update_progress_book_path(book), params: { pages_read: 20 }
          expect(book.reload.current_page).to eq(30)
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
      end

      context '現在ページを直接入力（direct_page）で更新する場合' do
        it 'current_page が指定した値に更新される' do
          book = create(:book, user: user, current_page: 10, target_pages: 200)
          patch update_progress_book_path(book), params: { direct_page: 50 }
          expect(book.reload.current_page).to eq(50)
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
end
