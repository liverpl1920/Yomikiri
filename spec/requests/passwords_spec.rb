require 'rails_helper'

RSpec.describe 'Passwords', type: :request do
  describe 'GET /users/password/new' do
    it 'パスワード再設定リクエストページが表示される' do
      get new_user_password_path

      expect(response).to have_http_status(:ok)
    end

    it 'メールアドレス入力フォームが含まれる' do
      get new_user_password_path

      expect(response.body).to include('再設定メールを送信')
      expect(response.body).to include('メールアドレス')
    end

    it 'ログイン画面に戻るリンクが含まれる' do
      get new_user_password_path

      expect(response.body).to include('ログイン画面に戻る')
    end
  end

  describe 'POST /users/password' do
    context '登録済みのメールアドレスの場合' do
      let!(:user) { create(:user) }

      it 'リダイレクトされる' do
        post user_password_path, params: {
          user: { email: user.email }
        }

        expect(response).to have_http_status(:see_other)
      end
    end

    context '未登録のメールアドレスの場合（paranoidモード）' do
      it '登録済みの場合と同様にリダイレクトされる（ユーザー列挙対策）' do
        post user_password_path, params: {
          user: { email: 'notexist@example.com' }
        }

        expect(response).to have_http_status(:see_other)
      end
    end
  end

  describe 'PUT /users/password（W-14: パスワード変更）' do
    let!(:user) { create(:user) }

    context '有効なトークンと新パスワードの場合' do
      let(:token) { user.send_reset_password_instructions }

      it 'パスワードを変更してログイン画面へリダイレクトされる' do
        put user_password_path, params: {
          user: {
            reset_password_token: token,
            password: 'newpassword123',
            password_confirmation: 'newpassword123'
          }
        }

        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'パスワード変更後にログイン状態にならない（sign_in_after_reset_password=false）' do
        put user_password_path, params: {
          user: {
            reset_password_token: token,
            password: 'newpassword123',
            password_confirmation: 'newpassword123'
          }
        }

        follow_redirect!
        expect(response.body).to include('ログインする')
      end
    end

    context '無効なトークンの場合' do
      it 'エラーが表示される' do
        put user_password_path, params: {
          user: {
            reset_password_token: 'invalid_token',
            password: 'newpassword123',
            password_confirmation: 'newpassword123'
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
