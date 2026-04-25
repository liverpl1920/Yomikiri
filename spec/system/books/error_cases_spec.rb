# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '書籍詳細の異常系', type: :system do
  let!(:user) { create(:user) }
  let!(:book) { create(:book, user: user, title: '異常系テスト本', target_pages: 100, current_page: 10, deadline: Date.current + 7) }

  before do
    login_as(user, scope: :user)
    visit book_path(book)
  end

  describe '進捗更新の異常系' do
    it 'pages_readが0だとエラー表示される' do
      fill_in 'pages_read', with: 0
      click_button '更新する', match: :first

      expect(page).to have_text('ページ数が無効です')
      expect(book.reload.current_page).to eq(10)
    end

    it 'pages_readが負値だとエラー表示される' do
      fill_in 'pages_read', with: -1
      click_button '更新する', match: :first

      expect(page).to have_text('ページ数が無効です')
      expect(book.reload.current_page).to eq(10)
    end

    it 'direct_pageがtarget_pagesを超えるとエラー表示される' do
      fill_in 'direct_page', with: 150, visible: :all
      within('#direct-input-section', visible: :all) do
        click_button '更新する', visible: :all
      end

      expect(page).to have_text('ページ数が無効です')
      expect(book.reload.current_page).to eq(10)
    end
  end

  describe '期限延長の異常系' do
    def open_extend_modal
      expect(page).to have_css('.modal-overlay[data-modal-target="extendOverlay"]', visible: :all)
    end

    it '同じ日付を指定するとエラー表示される' do
      open_extend_modal
      within('.modal-overlay[data-modal-target="extendOverlay"]', visible: :all) do
        fill_in 'deadline', with: book.deadline.strftime('%Y-%m-%d'), visible: :all
        click_button '延長する', visible: :all
      end

      expect(page).to have_text('現在の期限より後の日付を指定してください')
      expect(book.reload.deadline).to eq(Date.current + 7)
    end

    it '現在期限より前の日付を指定するとエラー表示される' do
      open_extend_modal
      within('.modal-overlay[data-modal-target="extendOverlay"]', visible: :all) do
        fill_in 'deadline', with: (Date.current + 1).strftime('%Y-%m-%d'), visible: :all
        click_button '延長する', visible: :all
      end

      expect(page).to have_text('現在の期限より後の日付を指定してください')
      expect(book.reload.deadline).to eq(Date.current + 7)
    end

    it '不正な日付形式を指定するとエラー表示される' do
      open_extend_modal
      within('.modal-overlay[data-modal-target="extendOverlay"]', visible: :all) do
        fill_in 'deadline', with: 'not-a-date', visible: :all
        click_button '延長する', visible: :all
      end

      expect(page).to have_text('読了期限')
      expect(book.reload.deadline).to eq(Date.current + 7)
    end
  end
end
