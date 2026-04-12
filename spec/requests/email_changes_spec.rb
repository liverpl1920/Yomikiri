# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'EmailChanges', type: :request do
  let(:user) { create(:user) }

  describe 'GET /email_change/edit (W-15)' do
    context '未ログインの場合' do
      it 'ログイン画面へリダイレクトされる' do
        get edit_email_change_path

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'ログイン済みの場合' do
      before { sign_in user }

      it '200 OK を返す' do
        get edit_email_change_path

        expect(response).to have_http_status(:ok)
      end

      it 'メールアドレス変更フォームが表示される' do
        get edit_email_change_path

        expect(response.body).to include('メールアドレスの変更')
        expect(response.body).to include('確認メールを送信')
        expect(response.body).to include('現在のパスワード')
      end

      it 'マイページへ戻るリンクが表示される' do
        get edit_email_change_path

        expect(response.body).to include('マイページに戻る')
      end
    end
  end

  describe 'PATCH /email_change' do
    context '未ログインの場合' do
      it 'ログイン画面へリダイレクトされる' do
        patch email_change_path, params: {
          email: 'new@example.com',
          current_password: 'password123'
        }

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'ログイン済みの場合' do
      before { sign_in user }

      context '正しいパスワードと新しいメールアドレスを入力した場合' do
        it 'マイページへリダイレクトされる' do
          patch email_change_path, params: {
            email: 'newemail@example.com',
            current_password: 'password123'
          }

          expect(response).to redirect_to(mypage_path)
        end

        it 'フラッシュメッセージが表示される' do
          patch email_change_path, params: {
            email: 'newemail@example.com',
            current_password: 'password123'
          }

          expect(flash[:notice]).to include('確認メールを送信しました')
        end

        it 'unconfirmed_email が更新される' do
          patch email_change_path, params: {
            email: 'newemail@example.com',
            current_password: 'password123'
          }

          user.reload
          expect(user.unconfirmed_email).to eq('newemail@example.com')
        end
      end

      context 'パスワードが間違っている場合' do
        it '422 Unprocessable Entity を返す' do
          patch email_change_path, params: {
            email: 'newemail@example.com',
            current_password: 'wrongpassword'
          }

          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'エラーメッセージが表示される' do
          patch email_change_path, params: {
            email: 'newemail@example.com',
            current_password: 'wrongpassword'
          }

          expect(response.body).to include('が違います')
        end
      end

      context '既に使用中のメールアドレスを入力した場合' do
        let!(:other_user) { create(:user, email: 'taken@example.com') }

        it '422 Unprocessable Entity を返す' do
          patch email_change_path, params: {
            email: 'taken@example.com',
            current_password: 'password123'
          }

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  describe 'GET /email_change/complete (W-17)' do
    it '200 OK を返す' do
      get email_change_complete_path

      expect(response).to have_http_status(:ok)
    end

    it 'メールアドレス変更完了メッセージが表示される' do
      get email_change_complete_path

      expect(response.body).to include('メールアドレスの変更完了')
    end

    it 'ログイン画面へのリンクが表示される' do
      get email_change_complete_path

      expect(response.body).to include('ログイン画面へ')
    end
  end
end
