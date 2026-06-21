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

  def type_in_field(selector, text)
    page.execute_script(
      "const el = document.querySelector(#{selector.to_json});" \
      "el.focus();" \
      "el.value = #{text.to_json};" \
      "el.dispatchEvent(new Event('input', { bubbles: true }));"
    )
    sleep 0.5
  end

  def press_key_on(selector, key)
    page.execute_script(
      "document.querySelector(#{selector.to_json})" \
      ".dispatchEvent(new KeyboardEvent('keydown', { key: #{key.to_json}, bubbles: true, cancelable: true }));"
    )
  end

  def js_click(element)
    page.execute_script('arguments[0].click();', element)
  end

  before do
    Warden.instance_variable_set(:@test_mode, false)
    sign_in_via_form(user)
    visit books_path
    wait_for_stimulus(identifier: 'search-toggle')

    page.execute_script("document.querySelector('.books-index__search-toggle-btn').click()")
    expect(page).to have_css('.books-index__search-toggle-btn[aria-expanded="true"]', wait: 15)

    wait_for_stimulus(identifier: 'search-filter-autocomplete')
    sleep 0.5
  end

  describe '著者名フィールドのオートコンプリート' do
    it '入力すると候補ドロップダウンが表示される' do
      type_in_field('#author', 'Dustin')

      expect(page).to have_css(
        '[data-search-filter-autocomplete-field-value="author"] .search-filter-autocomplete__list:not(.search-filter-autocomplete__list--hidden)',
        wait: 15
      )
      expect(page).to have_css('[data-search-filter-autocomplete-field-value="author"] .search-filter-autocomplete__item', wait: 15)
    end

    it '候補に著者名が含まれる' do
      type_in_field('#author', 'Dustin')

      expect(page).to have_button('Dustin Boswell', wait: 15)
    end

    it '候補をクリックすると入力フィールドに値がセットされる' do
      type_in_field('#author', 'Dustin')

      expect(page).to have_button('Dustin Boswell', wait: 15)
      js_click(find_button('Dustin Boswell'))

      expect(page).to have_field('著者名', with: 'Dustin Boswell', wait: 15)
    end

    it '候補選択後にドロップダウンが閉じる' do
      type_in_field('#author', 'Dustin')

      expect(page).to have_button('Dustin Boswell', wait: 15)
      js_click(find_button('Dustin Boswell'))

      expect(page).not_to have_css(
        '[data-search-filter-autocomplete-field-value="author"] .search-filter-autocomplete__list:not(.search-filter-autocomplete__list--hidden)',
        wait: 15
      )
    end

    it 'Enterキーで候補を選択できる' do
      type_in_field('#author', 'Dustin')

      expect(page).to have_css('[data-search-filter-autocomplete-field-value="author"] .search-filter-autocomplete__item', wait: 15)
      press_key_on('#author', 'ArrowDown')
      press_key_on('#author', 'Enter')

      expect(page).to have_field('著者名', with: 'Dustin Boswell', wait: 15)
    end

    it 'Escキーでドロップダウンが閉じる' do
      type_in_field('#author', 'Dustin')

      expect(page).to have_css(
        '[data-search-filter-autocomplete-field-value="author"] .search-filter-autocomplete__list:not(.search-filter-autocomplete__list--hidden)',
        wait: 15
      )
      press_key_on('#author', 'Escape')

      expect(page).not_to have_css(
        '[data-search-filter-autocomplete-field-value="author"] .search-filter-autocomplete__list:not(.search-filter-autocomplete__list--hidden)',
        wait: 15
      )
    end

    it '他ユーザーの著者名は候補に表示されない' do
      other_user = create(:user)
      create(:book, user: other_user, author: 'OtherUserAuthor', deadline: Date.current + 5)

      type_in_field('#author', 'OtherUser')

      sleep 0.8
      expect(page).not_to have_css(
        '[data-search-filter-autocomplete-field-value="author"] .search-filter-autocomplete__list:not(.search-filter-autocomplete__list--hidden)'
      )
    end
  end

  describe 'ジャンルフィールドのオートコンプリート' do
    it '入力すると候補ドロップダウンが表示される' do
      type_in_field('#genre', 'プログラミング')

      expect(page).to have_css(
        '[data-search-filter-autocomplete-field-value="genre"] .search-filter-autocomplete__list:not(.search-filter-autocomplete__list--hidden)',
        wait: 15
      )
    end

    it '候補をクリックすると入力フィールドに値がセットされる' do
      type_in_field('#genre', 'プログラミング')

      expect(page).to have_button('プログラミング', wait: 15)
      js_click(find_button('プログラミング'))

      expect(page).to have_field('ジャンル', with: 'プログラミング', wait: 15)
    end
  end

  describe '出版社フィールドのオートコンプリート' do
    let!(:book_oreilly) do
      create(:book, user: user, publisher: 'オライリー・ジャパン',
                    deadline: Date.current + 5)
    end

    before do
      visit books_path
      wait_for_stimulus(identifier: 'search-toggle')

      page.execute_script("document.querySelector('.books-index__search-toggle-btn').click()")
      expect(page).to have_css('.books-index__search-toggle-btn[aria-expanded="true"]', wait: 15)

      wait_for_stimulus(identifier: 'search-filter-autocomplete')
      sleep 0.5
    end

    it '入力すると候補ドロップダウンが表示される' do
      type_in_field('#publisher', 'オライリー')

      expect(page).to have_css(
        '[data-search-filter-autocomplete-field-value="publisher"] .search-filter-autocomplete__list:not(.search-filter-autocomplete__list--hidden)',
        wait: 15
      )
    end

    it '候補に出版社名が含まれる' do
      type_in_field('#publisher', 'オライリー')

      expect(page).to have_button('オライリー・ジャパン', wait: 15)
    end

    it '候補をクリックすると入力フィールドに値がセットされる' do
      type_in_field('#publisher', 'オライリー')

      expect(page).to have_button('オライリー・ジャパン', wait: 15)
      js_click(find_button('オライリー・ジャパン'))

      expect(page).to have_field('出版社', with: 'オライリー・ジャパン', wait: 15)
    end
  end

  describe '翻訳者フィールドのオートコンプリート' do
    let!(:book_translated) do
      create(:book, user: user, translator: '田中太郎',
                    deadline: Date.current + 5)
    end

    before do
      visit books_path
      wait_for_stimulus(identifier: 'search-toggle')

      page.execute_script("document.querySelector('.books-index__search-toggle-btn').click()")
      expect(page).to have_css('.books-index__search-toggle-btn[aria-expanded="true"]', wait: 15)

      wait_for_stimulus(identifier: 'search-filter-autocomplete')
      sleep 0.5
    end

    it '入力すると候補ドロップダウンが表示される' do
      type_in_field('#translator', '田中')

      expect(page).to have_css(
        '[data-search-filter-autocomplete-field-value="translator"] .search-filter-autocomplete__list:not(.search-filter-autocomplete__list--hidden)',
        wait: 15
      )
    end

    it '候補に翻訳者名が含まれる' do
      type_in_field('#translator', '田中')

      expect(page).to have_button('田中太郎', wait: 15)
    end

    it '候補をクリックすると入力フィールドに値がセットされる' do
      type_in_field('#translator', '田中')

      expect(page).to have_button('田中太郎', wait: 15)
      js_click(find_button('田中太郎'))

      expect(page).to have_field('翻訳者', with: '田中太郎', wait: 15)
    end
  end
end
