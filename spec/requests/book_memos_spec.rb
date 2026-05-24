# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'BookMemos', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:book) { create(:book, user: user) }

  describe 'POST /books/:book_id/book_memos' do
    context '未ログインの場合' do
      it 'ログイン画面へリダイレクトされる' do
        post book_book_memos_path(book), params: { book_memo: { content: 'テストメモ' } }

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'ログイン済みの場合' do
      before { sign_in user }

      context '有効なパラメータの場合' do
        it '302リダイレクトを返す' do
          post book_book_memos_path(book), params: { book_memo: { content: 'テストメモ' } }

          expect(response).to redirect_to(book_path(book))
        end

        it 'メモが作成される' do
          expect {
            post book_book_memos_path(book), params: { book_memo: { content: 'テストメモ' } }
          }.to change(BookMemo, :count).by(1)
        end

        it '作成されたメモが書籍に関連付けられる' do
          post book_book_memos_path(book), params: { book_memo: { content: 'テストメモ' } }

          expect(book.book_memos.last.content).to eq('テストメモ')
        end
      end

      context '無効なパラメータの場合（contentが空）' do
        it '422を返す' do
          post book_book_memos_path(book), params: { book_memo: { content: '' } }

          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'メモが作成されない' do
          expect {
            post book_book_memos_path(book), params: { book_memo: { content: '' } }
          }.not_to change(BookMemo, :count)
        end
      end

      context '他ユーザーの書籍へのアクセス' do
        let(:other_book) { create(:book, user: other_user) }

        it '404を返す' do
          post book_book_memos_path(other_book), params: { book_memo: { content: 'テストメモ' } }

          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end

  describe 'DELETE /books/:book_id/book_memos/:id' do
    let!(:memo) { create(:book_memo, book: book) }

    context '未ログインの場合' do
      it 'ログイン画面へリダイレクトされる' do
        delete book_book_memo_path(book, memo)

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'ログイン済みの場合' do
      before { sign_in user }

      it '302リダイレクトを返す' do
        delete book_book_memo_path(book, memo)

        expect(response).to redirect_to(book_path(book))
      end

      it 'メモが削除される' do
        expect {
          delete book_book_memo_path(book, memo)
        }.to change(BookMemo, :count).by(-1)
      end

      context '他ユーザーの書籍のメモへのアクセス' do
        let(:other_book) { create(:book, user: other_user) }
        let!(:other_memo) { create(:book_memo, book: other_book) }

        it '404を返す' do
          delete book_book_memo_path(other_book, other_memo)

          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end
end
