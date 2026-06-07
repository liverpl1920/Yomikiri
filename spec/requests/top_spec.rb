# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Top', type: :request do
  describe 'GET /' do
    context '未ログインの場合' do
      it 'Top画面が表示される' do
        get root_path

        expect(response).to have_http_status(:ok)
      end
    end

    context 'ログイン済みの場合' do
      let(:user) { create(:user) }

      before { sign_in user }

      it 'ダッシュボードページへリダイレクトされる' do
        get root_path

        expect(response).to redirect_to(dashboard_path)
      end
    end
  end
end
