# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '進捗更新', type: :system do
  let!(:user) { create(:user) }
  let!(:book) { create(:book, user: user, title: '進捗テスト本', total_pages: 200, target_pages: 200, current_page: 0) }

  describe '現在ページ入力フォーム（非JS）' do
    before { login_as(user, scope: :user) }

    it '現在ページを入力して進捗を更新できる' do
      visit book_path(book)

      fill_in 'direct_page', with: 30
      click_button '更新する'

      expect(page).to have_current_path(book_path(book))
      expect(page).to have_text('進捗を更新しました')
      expect(page).to have_text('30 / 200')
    end

    it 'ページ数が負の場合はエラーが表示される' do
      visit book_path(book)

      fill_in 'direct_page', with: -1
      click_button '更新する'

      expect(page).to have_text('ページ数が無効です')
    end

    it '今日読んだページ数フォームと折りたたみボタンが表示されない' do
      visit book_path(book)

      expect(page).to have_no_field('pages_read')
      expect(page).to have_no_text('今日読んだページ数')
      expect(page).to have_no_button('現在ページを直接入力')
      expect(page).to have_field('direct_page')
    end
  end
end
