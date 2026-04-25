# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'パスワード再設定', type: :system do
  let!(:user) { create(:user, email: 'reset-target@example.com') }

  it 'ログイン画面から再設定画面へ遷移できる' do
    visit new_user_session_path

    click_link 'パスワードを忘れた場合'

    expect(page).to have_current_path(new_user_password_path)
    expect(page).to have_text('パスワード再設定')
  end

  it '登録済みメール/未登録メールのどちらでも同様に処理される' do
    visit new_user_password_path

    fill_in 'メールアドレス', with: user.email
    click_button '再設定メールを送信'
    expect(page).to have_current_path(new_user_session_path)

    visit new_user_password_path
    fill_in 'メールアドレス', with: 'notexist@example.com'
    click_button '再設定メールを送信'
    expect(page).to have_current_path(new_user_session_path)
  end

  it '有効なトークンでパスワードを変更後、ログイン画面へ遷移する' do
    token = user.send_reset_password_instructions

    visit edit_user_password_path(reset_password_token: token)

    fill_in '新しいパスワード', with: 'newpassword123'
    fill_in '新しいパスワード（確認）', with: 'newpassword123'
    click_button 'パスワードを変更する'

    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_button('ログインする')

    fill_in 'メールアドレス', with: user.email
    fill_in 'パスワード', with: 'newpassword123'
    click_button 'ログインする'

    expect(page).to have_current_path(books_path)
  end
end
