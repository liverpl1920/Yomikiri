# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '進捗更新', type: :system do
  let!(:user) { create(:user) }
  let!(:book) { create(:book, user: user, title: '進捗テスト本', total_pages: 200, target_pages: 200, current_page: 0) }

  describe '今日読んだページ数フォーム（非JS）' do
    before { login_as(user, scope: :user) }

    it '今日読んだページ数を入力して進捗を更新できる' do
      visit book_path(book)

      fill_in 'pages_read', with: 30
      click_button '更新する'

      expect(page).to have_current_path(book_path(book))
      expect(page).to have_text('進捗を更新しました')
      expect(page).to have_text('30 / 200')
    end

    it 'ページ数が0の場合はエラーが表示される' do
      visit book_path(book)

      fill_in 'pages_read', with: 0
      click_button '更新する'

      expect(page).to have_text('ページ数が無効です')
    end
  end

  describe 'Stimulus インタラクション（JS）', js: true do
    before do
      Warden.instance_variable_set(:@test_mode, false)
      sign_in_via_form(user)
      visit book_path(book)
    end

    it '進捗更新フォームに +/− ボタンが表示されない' do
      visit book_path(book)
      wait_for_stimulus

      expect(page).to have_field('pages_read')
      expect(page).to have_no_css('[data-action~="click->progress-update#increment"]')
      expect(page).to have_no_css('[data-action~="click->progress-update#decrement"]')
    end

    it '「現在ページを直接入力」ボタンで折りたたみが展開する' do
      visit book_path(book)
      wait_for_stimulus

      expect(page).not_to have_css('#direct-input-section:not([hidden])')

      page.execute_script("document.querySelector('[data-action~=\"click->progress-update#toggleAdvanced\"]').click()")

      expect(page).to have_css('#direct-input-section:not([hidden])')
      expect(page).to have_field('direct_page')
    end
  end
end
