require 'rails_helper'

RSpec.describe 'UserRegistrations', type: :request do
  describe 'POST /users' do
    context '正しい情報で新規登録した場合' do
      it 'ダッシュボードページへリダイレクトされる' do
        post user_registration_path, params: {
          user: {
            email: 'newuser@example.com',
            password: 'password123',
            password_confirmation: 'password123',
            nickname: '新規ユーザー'
          }
        }

        expect(response).to redirect_to(dashboard_path)
      end
    end

    context '不正な情報で新規登録した場合' do
      it '登録に失敗してエラーが表示される' do
        post user_registration_path, params: {
          user: {
            email: 'invalid-email',
            password: 'password123',
            password_confirmation: 'wrong',
            nickname: ''
          }
        }

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
