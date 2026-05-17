# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ログイン・ログアウト', type: :system do
  let(:password) { 'password123' }
  let!(:user) { create(:user, password: password, password_confirmation: password) }

  describe 'ログインフォーム' do
    it '正しい認証情報でログインできる' do
      visit new_user_session_path

      fill_in 'メールアドレス', with: user.email
      fill_in 'パスワード', with: password
      click_button 'ログインする'

      expect(page).to have_current_path(books_path)
    end

    it '誤ったパスワードではログインに失敗してエラーメッセージが表示される' do
      visit new_user_session_path

      fill_in 'メールアドレス', with: user.email
      fill_in 'パスワード', with: 'wrongpassword'
      click_button 'ログインする'

      expect(page).to have_text('メールアドレスまたはパスワードが正しくありません')
    end

    it '存在しないメールアドレスではログインに失敗する' do
      visit new_user_session_path

      fill_in 'メールアドレス', with: 'noexist@example.com'
      fill_in 'パスワード', with: password
      click_button 'ログインする'

      expect(page).to have_text('メールアドレスまたはパスワードが正しくありません')
    end

    it 'ログイン済みの場合はログイン画面から積読一覧へリダイレクトされる' do
      login_as(user, scope: :user)
      visit new_user_session_path

      expect(page).to have_current_path(books_path)
    end
  end

  describe 'ログアウト', js: true do
    it 'ドロップダウンメニューからログアウトできる' do
      sign_in_via_form(user, password: password)
      visit root_path

      wait_for_stimulus
      expect(page).to have_css('.dropdown__trigger')

      # ドロップダウン内のログアウトフォームを確実に送信する
      execute_script(%q{document.querySelector('.dropdown__logout-form').requestSubmit()})

      expect(page).to have_current_path(root_path)
      expect(page).to have_link('ログイン')
    end
  end
end
