require 'rails_helper'

RSpec.describe 'Header and Footer', type: :request do
  describe 'GET /' do
    context '未ログイン時' do
      it 'ゲスト用ヘッダーが表示される（ログインリンクと新規登録リンクがある）' do
        get root_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('ログイン')
        expect(response.body).to include('無料で始める')
      end

      it 'ログアウトリンクが表示されない' do
        get root_path

        expect(response.body).not_to include('ログアウト')
      end

      it '共通フッターが表示される' do
        get root_path

        expect(response.body).to include('site-footer')
        expect(response.body).to include('All rights reserved')
      end
    end

    context 'ログイン済み時' do
      let(:user) { create(:user) }

      before { sign_in user }

      it 'ユーザー用ヘッダーが表示される（ドロップダウンがある）' do
        get root_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('dropdown')
      end

      it 'ログアウトリンクが表示される' do
        get root_path

        expect(response.body).to include('ログアウト')
      end

      it 'マイページリンクが表示される' do
        get root_path

        expect(response.body).to include('マイページ')
      end

      it '共通フッターが表示される' do
        get root_path

        expect(response.body).to include('site-footer')
        expect(response.body).to include('All rights reserved')
      end
    end
  end
end
