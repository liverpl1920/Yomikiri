# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '書籍詳細のUI状態', type: :system do
  let!(:user) { create(:user) }

  before { login_as(user, scope: :user) }

  describe '期限警告表示' do
    it '残り7日でurgent-lowが表示される' do
      book = create(:book, user: user, title: 'low本', deadline: Date.current + 6)

      visit book_path(book)

      expect(page).to have_css('.book-show__cover.book-card__cover--urgent-low')
      expect(page).to have_text('あと7日')
    end

    it '残り3日でurgent-mediumが表示される' do
      book = create(:book, user: user, title: 'medium本', deadline: Date.current + 2)

      visit book_path(book)

      expect(page).to have_css('.book-show__cover.book-card__cover--urgent-medium')
      expect(page).to have_text('あと3日')
    end

    it '残り1日でurgent-highと期限間近バッジが表示される' do
      book = create(:book, user: user, title: 'high本', deadline: Date.current)

      visit book_path(book)

      expect(page).to have_css('.book-show__cover.book-card__cover--urgent-high')
      expect(page).to have_text('期限間近！')
    end

    it '残り8日以上では警告クラスが表示されない' do
      book = create(:book, user: user, title: 'normal本', deadline: Date.current + 7)

      visit book_path(book)

      expect(page).to have_css('.book-show__cover:not(.book-card__cover--urgent-low):not(.book-card__cover--urgent-medium):not(.book-card__cover--urgent-high)')
      expect(page).not_to have_css('.book-show__urgency-badge')
    end

    it '読了済みでは警告クラスが表示されない' do
      book = create(:book, user: user, title: 'done本', status: :completed, current_page: 100, target_pages: 100, deadline: Date.current)

      visit book_path(book)

      expect(page).to have_css('.book-show__cover:not(.book-card__cover--urgent-low):not(.book-card__cover--urgent-medium):not(.book-card__cover--urgent-high)')
      expect(page).not_to have_css('.book-show__urgency-badge')
    end
  end

  describe 'Googleカレンダー連携セクション' do
    it '連携セクションとデフォルト30分が表示される' do
      book = create(:book, user: user, title: 'カレンダーテスト本')

      visit book_path(book)

      expect(page).to have_text('Googleカレンダーで予定を作る')
      expect(page).to have_css('[data-controller="google-calendar"]')
      duration_radio = find('input[name="gcal_duration"][value="30"]', visible: :all)
      expect(duration_radio.checked?).to be(true)
      expect(page).to have_text('MVPでは、Google側での予定の変更・削除はアプリ内に反映されません')
    end
  end
end
