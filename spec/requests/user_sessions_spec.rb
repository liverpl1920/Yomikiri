require 'rails_helper'

RSpec.describe 'UserSessions', type: :request do
  describe 'GET /users/sign_in' do
    it 'ログインページが表示される' do
      get new_user_session_path

      expect(response).to have_http_status(:ok)
    end

    it 'ログインフォームが含まれる' do
      get new_user_session_path

      expect(response.body).to include('ログインする')
      expect(response.body).to include('メールアドレス')
      expect(response.body).to include('パスワード')
    end

    it '新規登録リンクが含まれる' do
      get new_user_session_path

      expect(response.body).to include('新規登録')
    end

    it 'パスワードを忘れた場合のリンクが含まれる' do
      get new_user_session_path

      expect(response.body).to include('パスワードを忘れた場合')
    end

    context 'ログイン済みの場合' do
      let(:user) { create(:user) }

      before { sign_in user }

      it '積読一覧ページへリダイレクトされる' do
        get new_user_session_path

        expect(response).to redirect_to(books_path)
      end
    end
  end

  describe 'POST /users/sign_in' do
    let(:password) { 'password123' }
    let!(:user) { create(:user, password: password, password_confirmation: password) }

    context '正しい認証情報の場合' do
      it 'ログインに成功してリダイレクトされる' do
        post user_session_path, params: {
          user: { email: user.email, password: password }
        }

        expect(response).to have_http_status(:see_other)
      end

      it 'ログイン後はログイン画面にアクセスできない' do
        post user_session_path, params: {
          user: { email: user.email, password: password }
        }

        get new_user_session_path
        expect(response).to redirect_to(books_path)
      end
    end

    context '誤ったパスワードの場合' do
      it 'ログインに失敗してエラーメッセージが表示される' do
        post user_session_path, params: {
          user: { email: user.email, password: 'wrongpassword' }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('メールアドレスまたはパスワードが正しくありません')
      end
    end

    context '存在しないメールアドレスの場合' do
      it 'ログインに失敗してエラーメッセージが表示される' do
        post user_session_path, params: {
          user: { email: 'nonexistent@example.com', password: password }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('メールアドレスまたはパスワードが正しくありません')
      end
    end
  end

  describe 'DELETE /users/sign_out' do
    let(:user) { create(:user) }

    before { sign_in user }

    it 'ログアウトに成功してリダイレクトされる' do
      delete destroy_user_session_path

      expect(response).to have_http_status(:see_other)
    end

    it 'ログアウト後にTOPページへリダイレクトされる' do
      delete destroy_user_session_path

      expect(response).to redirect_to(root_path)
    end
  end

  describe 'DELETE /users/sign_out セッション破棄' do
    let(:user) { create(:user) }

    it 'ログアウト後にセッションが破棄される' do
      # Warden test helperを使わずPOSTで実際にログインし、セッション破棄を検証する
      post user_session_path, params: { user: { email: user.email, password: 'password123' } }
      delete destroy_user_session_path
      follow_redirect!

      expect(response).to have_http_status(:ok)
      # ログアウトボタン（ドロップダウン）が表示されないことを確認
      # flash messageに「ログアウトしました」が含まれるため文字列検索ではなくCSSクラスで確認
      expect(response.body).not_to include('dropdown__item--logout')
      # ゲスト用ナビが表示されていることを確認
      expect(response.body).to include('無料で始める')
    end
  end
end
