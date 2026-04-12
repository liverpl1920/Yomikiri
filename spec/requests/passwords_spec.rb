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

    context '未登録のメールアドレスの場合' do
      it 'エラーが表示される' do
        post user_password_path, params: {
          user: { email: 'notexist@example.com' }
        }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
