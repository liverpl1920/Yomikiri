# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mypages', type: :request do
  let(:user) { create(:user) }

  describe 'GET /mypage' do
    context '未ログインの場合' do
      it 'ログイン画面へリダイレクトされる' do
        get mypage_path

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'ログイン済みの場合' do
      before { sign_in user }

      it '200 OK を返す' do
        get mypage_path

        expect(response).to have_http_status(:ok)
      end

      it 'ユーザーのニックネームが表示される' do
        get mypage_path

        expect(response.body).to include(user.nickname)
      end

      it 'ユーザーのメールアドレスが表示される' do
        get mypage_path

        expect(response.body).to include(user.email)
      end

      it '年間目標が表示される' do
        get mypage_path

        expect(response.body).to include("#{user.yearly_goal} 冊")
      end

      context 'ニックネームが未設定の場合' do
        let(:user) { create(:user, nickname: nil) }

        it 'メールアドレスが表示される' do
          get mypage_path

          expect(response.body).to include(user.email)
        end
      end

      context '読了した本がある場合' do
        let!(:completed_book) do
          create(:book, user: user, status: :completed, completed_at: 1.day.ago)
        end

        it '読了履歴が表示される' do
          get mypage_path

          expect(response.body).to include(completed_book.title)
        end
      end

      context '読了した本がない場合' do
        it '読了履歴が空であることを表示する' do
          get mypage_path

          expect(response.body).to include('読了した本はまだありません')
        end
      end
    end
  end

  describe 'PATCH /mypage' do
    context '未ログインの場合' do
      it 'ログイン画面へリダイレクトされる' do
        patch mypage_path, params: { user: { nickname: '新ニックネーム' } }

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'ログイン済みの場合' do
      before { sign_in user }

      context '有効なニックネームや年間目標を入力した場合' do
        it 'ニックネームと年間目標が更新されてマイページへリダイレクトされる' do
          patch mypage_path, params: { user: { nickname: '新ニックネーム', yearly_goal: 30 } }

          expect(response).to redirect_to(mypage_path)
          expect(user.reload.nickname).to eq('新ニックネーム')
          expect(user.reload.yearly_goal).to eq(30)
        end

        it '空文字でニックネームをクリアできる' do
          patch mypage_path, params: { user: { nickname: '' } }

          expect(response).to redirect_to(mypage_path)
          expect(user.reload.nickname).to eq('')
        end
      end

      context '無効なニックネームや年間目標を入力した場合' do
        it 'ニックネームが51文字以上の場合は422を返す' do
          patch mypage_path, params: { user: { nickname: 'a' * 51 } }

          expect(response).to have_http_status(:unprocessable_entity)
        end

        it '年間目標が0以下の場合は422を返す' do
          patch mypage_path, params: { user: { yearly_goal: 0 } }

          expect(response).to have_http_status(:unprocessable_entity)
        end

        it '年間目標が小数の場合は422を返す' do
          patch mypage_path, params: { user: { yearly_goal: 1.5 } }

          expect(response).to have_http_status(:unprocessable_entity)
        end

        it '年間目標が空の場合は422を返す' do
          patch mypage_path, params: { user: { yearly_goal: '' } }

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
