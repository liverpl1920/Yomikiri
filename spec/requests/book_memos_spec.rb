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
        it 'turbo_streamリクエスト時に200を返す' do
          post book_book_memos_path(book),
               params: { book_memo: { content: 'テストメモ' } },
               headers: { 'Accept' => 'text/vnd.turbo-stream.html, text/html' }

          expect(response).to have_http_status(:ok)
        end

        it 'turbo_streamリクエスト時にturbo-streamコンテントタイプでレスポンスする' do
          post book_book_memos_path(book),
               params: { book_memo: { content: 'テストメモ' } },
               headers: { 'Accept' => 'text/vnd.turbo-stream.html, text/html' }

          expect(response.content_type).to include('text/vnd.turbo-stream.html')
        end

        it 'HTMLリクエスト時に302リダイレクトを返す' do
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

        it '装飾記法を含むメモを保存できる' do
          content = 'これは**重要**です [color=#ff0000]確認[/color]'

          post book_book_memos_path(book), params: { book_memo: { content: content } }

          expect(book.book_memos.last.content).to eq(content)
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

      context '読書ログがある状態で無効なパラメータ（contentが空）の場合' do
        before do
          create(:reading_log, book: book, read_at: Date.current - 1, pages_read: 10)
        end

        it '422を返し、グラフデータが正しく設定される' do
          post book_book_memos_path(book), params: { book_memo: { content: '' } }

          expect(response).to have_http_status(:unprocessable_entity)
          chart_data = controller.instance_variable_get(:@progress_chart_data)
          expect(chart_data).to be_present
          expect(chart_data.first).to include(:cumulative_pages)
          expect(controller.instance_variable_get(:@progress_chart_max_pages)).to eq(book.pages)
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

  describe 'GET /books/:book_id/book_memos/:id/edit' do
    let!(:memo) { create(:book_memo, book: book) }

    context '未ログインの場合' do
      it 'ログイン画面へリダイレクトされる' do
        get edit_book_book_memo_path(book, memo)

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'ログイン済みの場合' do
      before { sign_in user }

      it '200を返す' do
        get edit_book_book_memo_path(book, memo)

        expect(response).to have_http_status(:ok)
      end

      context '他ユーザーの書籍のメモへのアクセス' do
        let(:other_book) { create(:book, user: other_user) }
        let!(:other_memo) { create(:book_memo, book: other_book) }

        it '404を返す' do
          get edit_book_book_memo_path(other_book, other_memo)

          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end

  describe 'PATCH /books/:book_id/book_memos/:id' do
    let!(:memo) { create(:book_memo, book: book) }

    context '未ログインの場合' do
      it 'ログイン画面へリダイレクトされる' do
        patch book_book_memo_path(book, memo), params: { book_memo: { content: '更新後のメモ' } }

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'ログイン済みの場合' do
      before { sign_in user }

      context '有効なパラメータの場合' do
        it '302リダイレクトを返す' do
          patch book_book_memo_path(book, memo), params: { book_memo: { content: '更新後のメモ' } }

          expect(response).to redirect_to(book_path(book))
        end

        it 'メモが更新される' do
          patch book_book_memo_path(book, memo), params: { book_memo: { content: '更新後のメモ' } }

          expect(memo.reload.content).to eq('更新後のメモ')
        end

        it 'page_numberが更新される' do
          patch book_book_memo_path(book, memo), params: { book_memo: { content: memo.content, page_number: '100-120' } }

          expect(memo.reload.page_number).to eq('100-120')
        end

        it '装飾記法を含むメモに更新できる' do
          formatted = '**強調** [color=#1d4ed8]青文字[/color]'

          patch book_book_memo_path(book, memo), params: { book_memo: { content: formatted } }

          expect(memo.reload.content).to eq(formatted)
        end
      end

      context '無効なパラメータの場合（contentが空）' do
        it '422を返す' do
          patch book_book_memo_path(book, memo), params: { book_memo: { content: '' } }

          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'メモが更新されない' do
          original_content = memo.content
          patch book_book_memo_path(book, memo), params: { book_memo: { content: '' } }

          expect(memo.reload.content).to eq(original_content)
        end
      end

      context '他ユーザーの書籍のメモへのアクセス' do
        let(:other_book) { create(:book, user: other_user) }
        let!(:other_memo) { create(:book_memo, book: other_book) }

        it '404を返す' do
          patch book_book_memo_path(other_book, other_memo), params: { book_memo: { content: '更新後のメモ' } }

          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end

  describe 'POST /books/:book_id/book_memos (page_number付き)' do
    context 'ログイン済みの場合' do
      before { sign_in user }

      it 'page_numberが保存される' do
        post book_book_memos_path(book), params: { book_memo: { content: 'テストメモ', page_number: '100' } }

        expect(book.book_memos.last.page_number).to eq('100')
      end

      it 'page_numberが未入力でも作成できる' do
        post book_book_memos_path(book), params: { book_memo: { content: 'テストメモ', page_number: '' } }

        expect(book.book_memos.last.page_number).to be_blank
      end
    end
  end

  describe 'GET /books/:id (メモ表示)' do
    before { sign_in user }

    it '太字と文字色が変換されず、プレーンテキストとして表示される' do
      create(:book_memo, book: book, content: '**重要** [color=#ff0000]要確認[/color]')

      get book_path(book)

      expect(response.body).to include('**重要** [color=#ff0000]要確認[/color]')
      expect(response.body).not_to include('<strong>重要</strong>')
      expect(response.body).not_to include('style="color: #ff0000;"')
    end

    it '不正なHTMLはエスケープされる' do
      create(:book_memo, book: book, content: '<script>alert(1)</script>')

      get book_path(book)

      expect(response.body).not_to include('<script>alert(1)</script>')
      expect(response.body).to include('&lt;script&gt;alert(1)&lt;/script&gt;')
    end
  end
end
