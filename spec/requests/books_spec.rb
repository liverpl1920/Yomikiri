# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Books', type: :request do
  describe 'GET /books' do
    context '未ログインの場合' do
      it 'ログイン画面へリダイレクトされる' do
        get books_path

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'ログイン済みの場合' do
      let(:user) { create(:user) }

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

          # 期限が近い本が期限が遠い本より先に出現する
          expect(pos_near).to be < pos_far
          # 未了本が完了本より先に出現する
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

    context '他ユーザーの書籍は表示されない' do
      let(:user) { create(:user) }
      let(:other_user) { create(:user) }
      let!(:other_book) { create(:book, user: other_user) }

      before { sign_in user }

      it '他ユーザーの書籍が表示されない' do
        get books_path

        expect(response.body).not_to include(other_book.title)
      end
    end
  end
end
