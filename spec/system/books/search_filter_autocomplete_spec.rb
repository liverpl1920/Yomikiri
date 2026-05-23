# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '検索フィルターオートコンプリート機能', type: :system, js: true do
  let!(:user) { create(:user) }
  let!(:book_dustin) do
    create(:book, user: user, author: 'Dustin Boswell', genre: 'プログラミング',
                  deadline: Date.current + 10)
  end
  let!(:book_yamada) do
    create(:book, user: user, author: 'Yamada Taro', genre: 'ビジネス',
                  deadline: Date.current + 20)
  end

  def wait_for_search_filter_autocomplete_controller
    connected = false
    start = Time.now
    until Time.now - start > 10
      connected = page.evaluate_script(
        "window.Stimulus && window.Stimulus.controllers.some(c => c.identifier === 'search-filter-autocomplete')"
      )
      break if connected

      sleep 0.1
    end
    expect(connected).to be(true), 'search-filter-autocomplete controller did not connect within 10 seconds'
  end

  def type_in_field(selector, text)
    page.execute_script(
      "const el = document.querySelector(#{selector.to_json});" \
      "el.focus();" \
      "el.value = #{text.to_json};" \
      "el.dispatchEvent(new Event('input', { bubbles: true }));"
    )
  end

  def press_key_on(selector, key)
    page.execute_script(
      "document.querySelector(#{selector.to_json})" \
      ".dispatchEvent(new KeyboardEvent('keydown', { key: #{key.to_json}, bubbles: true, cancelable: true }));"
    )
  end

  before do
    Warden.instance_variable_set(:@test_mode, false)
    sign_in_via_form(user)
    visit books_path
    wait_for_stimulus
    wait_for_search_filter_autocomplete_controller
  end

  describe '著者名フィールドのオートコンプリート' do
    it '入力すると候補ドロップダウンが表示される' do
      type_in_field('#author', 'Dustin')

      expect(page).to have_css(
        '.search-filter-autocomplete__list:not(.search-filter-autocomplete__list--hidden)',
        wait: 5
      )
      expect(page).to have_css('.search-filter-autocomplete__item', wait: 5)
    end

    it '候補に著者名が含まれる' do
      type_in_field('#author', 'Dustin')

      expect(page).to have_css('.search-filter-autocomplete__button', text: 'Dustin Boswell', wait: 5)
    end

    it '候補をクリックすると入力フィールドに値がセットされる' do
      type_in_field('#author', 'Dustin')

      expect(page).to have_css('.search-filter-autocomplete__button', text: 'Dustin Boswell', wait: 5)
      find('.search-filter-autocomplete__button', text: 'Dustin Boswell').click

      expect(page).to have_field('著者名', with: 'Dustin Boswell', wait: 5)
    end

    it '候補選択後にドロップダウンが閉じる' do
      type_in_field('#author', 'Dustin')

      expect(page).to have_css('.search-filter-autocomplete__button', text: 'Dustin Boswell', wait: 5)
      find('.search-filter-autocomplete__button', text: 'Dustin Boswell').click

      expect(page).not_to have_css(
        '.search-filter-autocomplete__list:not(.search-filter-autocomplete__list--hidden)',
        wait: 3
      )
    end

    it 'Enterキーで候補を選択できる' do
      type_in_field('#author', 'Dustin')

      expect(page).to have_css('.search-filter-autocomplete__item', wait: 10)
      press_key_on('#author', 'ArrowDown')
      press_key_on('#author', 'Enter')

      expect(page).to have_field('著者名', with: 'Dustin Boswell', wait: 5)
    end

    it 'Escキーでドロップダウンが閉じる' do
      type_in_field('#author', 'Dustin')

      expect(page).to have_css(
        '.search-filter-autocomplete__list:not(.search-filter-autocomplete__list--hidden)',
        wait: 5
      )
      press_key_on('#author', 'Escape')

      expect(page).not_to have_css(
        '.search-filter-autocomplete__list:not(.search-filter-autocomplete__list--hidden)',
        wait: 3
      )
    end

    it '他ユーザーの著者名は候補に表示されない' do
      other_user = create(:user)
      create(:book, user: other_user, author: 'OtherUserAuthor', deadline: Date.current + 5)

      type_in_field('#author', 'OtherUser')

      sleep 0.8
      expect(page).not_to have_css(
        '.search-filter-autocomplete__list:not(.search-filter-autocomplete__list--hidden)'
      )
    end
  end

  describe 'ジャンルフィールドのオートコンプリート' do
    it '入力すると候補ドロップダウンが表示される' do
      type_in_field('#genre', 'プログラミング')

      expect(page).to have_css(
        '.search-filter-autocomplete__list:not(.search-filter-autocomplete__list--hidden)',
        wait: 5
      )
    end

    it '候補をクリックすると入力フィールドに値がセットされる' do
      type_in_field('#genre', 'プログラミング')

      expect(page).to have_css('.search-filter-autocomplete__button', text: 'プログラミング', wait: 5)
      find('.search-filter-autocomplete__button', text: 'プログラミング').click

      expect(page).to have_field('ジャンル', with: 'プログラミング', wait: 5)
    end
  end
end
