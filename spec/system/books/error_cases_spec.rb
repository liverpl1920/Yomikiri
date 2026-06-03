# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '書籍詳細の異常系', type: :system, js: true do
  let!(:user) { create(:user) }
  let!(:book) { create(:book, user: user, title: '異常系テスト本', target_pages: 100, current_page: 10, deadline: Date.current + 7) }

  before do
    Warden.test_reset!
    sign_in_via_form(user)
    visit book_path(book)
    wait_for_stimulus
  end

  describe '進捗更新の異常系' do
    it 'direct_pageが負値だとエラー表示される' do
      page.execute_script("document.getElementById('direct_page').removeAttribute('min')")
      page.execute_script("document.getElementById('direct_page').value = -1")
      progress_form = first('form[action="' + update_progress_book_path(book) + '"]', visible: :all)
      page.execute_script('arguments[0].noValidate = true; arguments[0].submit();', progress_form)

      expect(page).to have_text('ページ数が無効です')
      expect(book.reload.current_page).to eq(10)
    end

    it 'direct_pageがtarget_pagesを超えるとエラー表示される' do
      page.execute_script("document.getElementById('direct_page').removeAttribute('max')")
      page.execute_script("document.getElementById('direct_page').value = 150")
      direct_form = first('form[action="' + update_progress_book_path(book) + '"]', visible: :all)
      page.execute_script('arguments[0].noValidate = true; arguments[0].submit();', direct_form)

      expect(page).to have_text('ページ数が無効です')
      expect(book.reload.current_page).to eq(10)
    end
  end

  describe '期限延長の異常系' do
    def open_extend_modal
      page.execute_script("document.querySelector('[data-action=\"click->modal#openExtend\"]').click()")
      expect(page).to have_css('.modal-overlay[data-modal-target="extendOverlay"]:not([hidden])')
    end

    def submit_extend_form_with(value:, as_text: false)
      within('.modal-overlay[data-modal-target="extendOverlay"]', visible: :all) do
        deadline_input = find('#deadline')
        if as_text
          page.execute_script("arguments[0].setAttribute('type', 'text'); arguments[0].value = '#{value}'", deadline_input)
        else
          page.execute_script("arguments[0].value = '#{value}'", deadline_input)
        end

        extend_form = find('form', visible: :all)
        page.execute_script('arguments[0].noValidate = true; arguments[0].submit();', extend_form)
      end
    end

    it '同じ日付を指定するとエラー表示される' do
      open_extend_modal
      submit_extend_form_with(value: book.deadline.strftime('%Y-%m-%d'))

      expect(page).to have_text('現在の期限より後の日付を指定してください')
      expect(book.reload.deadline).to eq(Date.current + 7)
    end

    it '現在期限より前の日付を指定するとエラー表示される' do
      open_extend_modal
      submit_extend_form_with(value: (Date.current + 1).strftime('%Y-%m-%d'))

      expect(page).to have_text('現在の期限より後の日付を指定してください')
      expect(book.reload.deadline).to eq(Date.current + 7)
    end

    it '不正な日付形式を指定するとエラー表示される' do
      open_extend_modal
      submit_extend_form_with(value: 'not-a-date', as_text: true)

      expect(page).to have_text(/Translation missing|不正な値/)
      expect(book.reload.deadline).to eq(Date.current + 7)
    end
  end
end
