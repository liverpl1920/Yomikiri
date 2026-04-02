require 'rails_helper'

RSpec.describe 'Books', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  describe 'GET /books' do
    context '認証済みユーザーの場合' do
      before { sign_in user }

      it '200を返す' do
        get books_path
        expect(response).to have_http_status(:ok)
      end

      it '自分の書籍だけが表示される' do
        book = create(:book, user: user, title: '私の積読本')
        other_book = create(:book, user: other_user, title: '他ユーザーの積読本')
        get books_path
        expect(response.body).to include(book.title)
        expect(response.body).not_to include(other_book.title)
      end
    end

    context '未認証ユーザーの場合' do
      it 'ログインページへリダイレクトされる' do
        get books_path
        expect(response).to redirect_to(new_user_session_path)
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
    end

    context '未認証ユーザーの場合' do
      it 'ログインページへリダイレクトされる' do
        book = create(:book, user: user)
        get book_path(book)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
