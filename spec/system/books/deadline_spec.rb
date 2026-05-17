# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '期限延長フロー', type: :system do
  let!(:user) { create(:user) }
  let!(:book) { create(:book, user: user, title: '期限テスト本', deadline: Date.current + 14) }

  describe '期限延長モーダル（JS）', js: true do
    before do
      Warden.instance_variable_set(:@test_mode, false)
      sign_in_via_form(user)
      visit book_path(book)
    end

    it '「期限を延長する」ボタンでモーダルが開く' do
      visit book_path(book)
      wait_for_stimulus

      page.execute_script("document.querySelector('[data-action=\"click->modal#openExtend\"]').click()")

      expect(page).to have_css('.modal-overlay[data-modal-target="extendOverlay"]:not([hidden])')
      expect(page).to have_text('読了期限の延長')
    end

    it 'キャンセルボタンでモーダルが閉じる' do
      visit book_path(book)
      wait_for_stimulus

      page.execute_script("document.querySelector('[data-action=\"click->modal#openExtend\"]').click()")
      expect(page).to have_css('.modal-overlay[data-modal-target="extendOverlay"]:not([hidden])')

      page.execute_script("document.querySelector('[data-action=\"click->modal#closeExtend\"]').click()")

      expect(page).not_to have_css('.modal-overlay[data-modal-target="extendOverlay"]:not([hidden])')
    end

    it '新しい期限を入力して延長するとフラッシュメッセージが表示される' do
      visit book_path(book)
      wait_for_stimulus

      page.execute_script("document.querySelector('[data-action=\"click->modal#openExtend\"]').click()")
      expect(page).to have_css('.modal-overlay[data-modal-target="extendOverlay"]:not([hidden])')

      new_deadline = (Date.current + 30).strftime('%Y-%m-%d')
      within('.modal-overlay[data-modal-target="extendOverlay"]', visible: :all) do
        deadline_input = find('#deadline')
        page.execute_script("arguments[0].value = '#{new_deadline}'", deadline_input)

        extend_form = find('form', visible: :all)
        page.execute_script('arguments[0].submit();', extend_form)
      end

      expect(page).to have_text('読了期限を延長しました')
    end
  end
end
