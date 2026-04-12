# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'UserPasswordChanges', type: :request do
  let(:password) { 'password123' }
  let(:user) { create(:user, password: password, password_confirmation: password) }

  describe 'GET /users/edit' do
    context '未ログインの場合' do
      it 'ログイン画面へリダイレクトされる' do
        get edit_user_registration_path

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'ログイン済みの場合' do
      before { sign_in user }

      it '200 OK を返す' do
        get edit_user_registration_path

        expect(response).to have_http_status(:ok)
      end

      it 'パスワード変更フォームが表示される' do
        get edit_user_registration_path

        expect(response.body).to include('パスワード変更')
      end
    end
  end

  describe 'PATCH /users' do
    context '未ログインの場合' do
      it 'ログイン画面へリダイレクトされる' do
        patch user_registration_path, params: {
          user: {
            current_password: password,
            password: 'newpassword123',
            password_confirmation: 'newpassword123'
          }
        }

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'ログイン済みの場合' do
      before { sign_in user }

      context '正しい現在パスワードで変更した場合' do
        it 'ログイン画面へリダイレクトされる' do
          patch user_registration_path, params: {
            user: {
              current_password: password,
              password: 'newpassword123',
              password_confirmation: 'newpassword123'
            }
          }

          expect(response).to redirect_to(new_user_session_path)
        end

        it 'パスワードが更新される' do
          patch user_registration_path, params: {
            user: {
              current_password: password,
              password: 'newpassword123',
              password_confirmation: 'newpassword123'
            }
          }

          expect(user.reload.valid_password?('newpassword123')).to be(true)
        end

        it 'サインアウト状態になる（再度ログインが必要）' do
          patch user_registration_path, params: {
            user: {
              current_password: password,
              password: 'newpassword123',
              password_confirmation: 'newpassword123'
            }
          }

          get books_path
          expect(response).to redirect_to(new_user_session_path)
        end
      end

      context '誤った現在パスワードを入力した場合' do
        it '422 を返す' do
          patch user_registration_path, params: {
            user: {
              current_password: 'wrongpassword',
              password: 'newpassword123',
              password_confirmation: 'newpassword123'
            }
          }

          expect(response).to have_http_status(:unprocessable_content)
        end
      end

      context '新しいパスワードと確認が一致しない場合' do
        it '422 を返す' do
          patch user_registration_path, params: {
            user: {
              current_password: password,
              password: 'newpassword123',
              password_confirmation: 'differentpassword'
            }
          }

          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end
  end
end
