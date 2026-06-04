# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '書籍一覧の検索トグル', type: :system, js: true do
  let!(:user) { create(:user) }
  let!(:book) { create(:book, user: user, title: 'RubyBook') }

  before do
    Warden.instance_variable_set(:@test_mode, false)
    sign_in_via_form(user)
  end

  describe '初期表示時のトグル状態' do
    context '検索パラメータが指定されていない場合' do
      it '検索フォームがデフォルトで非表示になっていること' do
        visit books_path
        wait_for_stimulus

        expect(page).to have_css('#books-search-form', visible: :hidden)
        button = find('.books-index__search-toggle-btn')
        expect(button['aria-expanded']).to eq('false')
      end
    end

    context '検索パラメータが指定されている場合' do
      it '検索フォームがデフォルトで表示されていること' do
        visit books_path(title: 'Ruby')
        wait_for_stimulus

        expect(page).to have_css('#books-search-form', visible: :visible)
        button = find('.books-index__search-toggle-btn')
        expect(button['aria-expanded']).to eq('true')
      end
    end
  end

  describe 'ボタン操作によるトグル切り替え' do
    it '検索ボタンをクリックすると表示・非表示が切り替わること' do
      visit books_path
      wait_for_stimulus

      expect(page).to have_css('#books-search-form', visible: :hidden)

      find('.books-index__search-toggle-btn').click
      expect(page).to have_css('#books-search-form', visible: :visible)
      expect(find('.books-index__search-toggle-btn')['aria-expanded']).to eq('true')

      find('.books-index__search-toggle-btn').click
      expect(page).to have_css('#books-search-form', visible: :hidden)
      expect(find('.books-index__search-toggle-btn')['aria-expanded']).to eq('false')
    end
  end
end
