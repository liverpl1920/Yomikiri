# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '新規ユーザー登録', type: :system do
  describe '新規登録フォーム' do
    it '正常な情報でユーザー登録ができ、ログイン状態になる' do
      visit new_user_registration_path

      fill_in 'user[email]', with: 'newuser@example.com'
      fill_in 'user[password]', with: 'password123'
      fill_in 'user[password_confirmation]', with: 'password123'
      click_button '登録する'

      # 登録成功後: registrations_controller の after_sign_up_path_for で books_path へリダイレクト
      # ヘッダーにログイン済みUI（ドロップダウン）が表示されることを確認
      expect(page).to have_css('.dropdown')
    end

    it 'パスワード確認不一致の場合にエラーが表示される' do
      visit new_user_registration_path

      fill_in 'user[email]', with: 'newuser@example.com'
      fill_in 'user[password]', with: 'password123'
      fill_in 'user[password_confirmation]', with: 'different_password'
      click_button '登録する'

      expect(page).to have_css('.auth-card__errors')
    end

    it 'ログイン済みの場合は登録ページへのアクセスがリダイレクトされる' do
      user = create(:user)
      login_as(user, scope: :user)

      visit new_user_registration_path

      # 既存ユーザーはページアクセスがリダイレクトされる
      expect(page).not_to have_button('登録する')
    end
  end
end
