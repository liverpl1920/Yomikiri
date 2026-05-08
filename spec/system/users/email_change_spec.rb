# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'メールアドレス変更', type: :system do
  let!(:user) { create(:user, password: 'password123', password_confirmation: 'password123') }

  describe '変更画面' do
    it '未ログイン時はログイン画面へ遷移する' do
      visit edit_email_change_path

      expect(page).to have_current_path(new_user_session_path)
    end

    it 'ログイン済み時にフォームが表示される' do
      login_as(user, scope: :user)

      visit edit_email_change_path

      expect(page).to have_text('メールアドレスの変更')
      expect(page).to have_field('新しいメールアドレス')
      expect(page).to have_field('現在のパスワード')
      expect(page).to have_button('確認メールを送信')
    end
  end

  describe '変更処理' do
    before do
      login_as(user, scope: :user)
      visit edit_email_change_path
    end

    it '正しいパスワードと新しいメールアドレスで更新できる' do
      fill_in '新しいメールアドレス', with: 'updated@example.com'
      fill_in '現在のパスワード', with: 'password123'
      click_button '確認メールを送信'

      expect(page).to have_current_path(mypage_path)
      expect(page).to have_text('確認メールを送信しました')
      expect(user.reload.unconfirmed_email).to eq('updated@example.com')
    end

    it 'パスワードが不正ならエラー表示される' do
      fill_in '新しいメールアドレス', with: 'updated@example.com'
      fill_in '現在のパスワード', with: 'wrongpassword'
      click_button '確認メールを送信'

      expect(page).to have_current_path(email_change_path)
      expect(page).to have_css('.auth-card__errors')
      expect(page).to have_text('現在のパスワードが違います')
    end

    it '同一メールアドレスはエラーになる' do
      fill_in '新しいメールアドレス', with: user.email
      fill_in '現在のパスワード', with: 'password123'
      click_button '確認メールを送信'

      expect(page).to have_current_path(email_change_path)
      expect(page).to have_text('現在のメールアドレスと同じものは設定できません')
    end

    it '既存利用中のメールアドレスはエラーになる' do
      create(:user, email: 'taken@example.com')

      fill_in '新しいメールアドレス', with: 'taken@example.com'
      fill_in '現在のパスワード', with: 'password123'
      click_button '確認メールを送信'

      expect(page).to have_current_path(email_change_path)
      expect(page).to have_css('.auth-card__errors')
      expect(user.reload.unconfirmed_email).to be_nil
    end
  end

  describe '完了画面' do
    it 'メールアドレス変更完了画面が表示される' do
      visit email_change_complete_path

      expect(page).to have_text('メールアドレスの変更完了')
      expect(page).to have_link('ログイン画面へ', href: new_user_session_path)
    end
  end
end
