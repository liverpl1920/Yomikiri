# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'タイトル入力中オートコンプリート機能', type: :system, js: true do
  let!(:user) { create(:user) }

  let(:google_books_multi_response) do
    {
      'items' => [
        {
          'volumeInfo' => {
            'title' => 'リーダブルコード',
            'authors' => [ 'Dustin Boswell' ],
            'pageCount' => 260,
            'industryIdentifiers' => [
              { 'type' => 'ISBN_13', 'identifier' => '9784873115658' }
            ],
            'imageLinks' => {}
          }
        },
        {
          'volumeInfo' => {
            'title' => 'リーダブルコード 実践編',
            'authors' => [ '山田太郎' ],
            'pageCount' => 180,
            'industryIdentifiers' => []
          }
        }
      ]
    }.to_json
  end

  let(:google_books_single_response) do
    {
      'items' => [
        {
          'volumeInfo' => {
            'title' => 'リーダブルコード',
            'authors' => [ 'Dustin Boswell' ],
            'pageCount' => 260,
            'industryIdentifiers' => [
              { 'type' => 'ISBN_13', 'identifier' => '9784873115658' }
            ],
            'imageLinks' => {}
          }
        }
      ]
    }.to_json
  end

  let(:google_books_empty_response) do
    { 'items' => [] }.to_json
  end

  let(:openbd_not_found_response) { [ nil ].to_json }

  def stub_google_books(response_body)
    stub_request(:get, /www\.googleapis\.com\/books\/v1\/volumes/)
      .to_return(status: 200, body: response_body,
                 headers: { 'Content-Type' => 'application/json' })
  end

  def stub_openbd_not_found
    stub_request(:get, /api\.openbd\.jp\/v1\/get/)
      .to_return(status: 200, body: openbd_not_found_response,
                 headers: { 'Content-Type' => 'application/json' })
  end

  def wait_for_title_autocomplete_controller
    connected = false
    start = Time.now
    until Time.now - start > 10
      connected = page.evaluate_script(
        "window.Stimulus && window.Stimulus.controllers.some(c => c.identifier === 'title-autocomplete')"
      )
      break if connected

      sleep 0.1
    end
    expect(connected).to be(true), 'title-autocomplete controller did not connect within 10 seconds'
  end

  before do
    WebMock.reset!
    Warden.instance_variable_set(:@test_mode, false)
    sign_in_via_form(user)
    visit new_book_path
    wait_for_stimulus
    wait_for_title_autocomplete_controller
  end

  describe '候補の表示' do
    before { stub_google_books(google_books_multi_response) }
    before { stub_openbd_not_found }

    it 'タイトルを入力すると候補ドロップダウンが表示される' do
      title_input = find('#book_title')
      title_input.send_keys('リーダブル')

      expect(page).to have_css('.title-autocomplete__list:not(.title-autocomplete__list--hidden)', wait: 5)
      expect(page).to have_css('.title-autocomplete__item', count: 2, wait: 5)
    end

    it '候補にタイトルと著者が含まれる' do
      title_input = find('#book_title')
      title_input.send_keys('リーダブル')

      expect(page).to have_css('.title-autocomplete__title', text: 'リーダブルコード', wait: 5)
      expect(page).to have_css('.title-autocomplete__author', text: 'Dustin Boswell', wait: 5)
    end

    it '2文字未満の入力では候補ドロップダウンが表示されない' do
      title_input = find('#book_title')
      title_input.send_keys('リ')

      sleep 0.5
      expect(page).not_to have_css(
        '.title-autocomplete__list:not(.title-autocomplete__list--hidden)'
      )
    end
  end

  describe '候補選択によるフォーム補完' do
    before do
      stub_google_books(google_books_multi_response)
      stub_openbd_not_found
    end

    it '候補をクリックするとフォームが補完される' do
      title_input = find('#book_title')
      title_input.send_keys('リーダブル')

      expect(page).to have_css('.title-autocomplete__item', wait: 5)
      first('.title-autocomplete__button').click

      expect(page).to have_field('タイトル', with: 'リーダブルコード', wait: 5)
      expect(page).to have_field('著者', with: 'Dustin Boswell', wait: 5)
      expect(page).to have_field('ページ数', with: '260', wait: 5, exact: true)
    end

    it '候補選択後にドロップダウンが閉じる' do
      title_input = find('#book_title')
      title_input.send_keys('リーダブル')

      expect(page).to have_css('.title-autocomplete__item', wait: 5)
      first('.title-autocomplete__button').click

      expect(page).not_to have_css(
        '.title-autocomplete__list:not(.title-autocomplete__list--hidden)',
        wait: 3
      )
    end
  end

  describe 'キーボード操作' do
    before do
      stub_google_books(google_books_multi_response)
      stub_openbd_not_found
    end

    # IME合成を経由せず直接inputイベントを発火する共通ヘルパー
    def type_in_title(text)
      page.execute_script(
        "const el = document.querySelector('#book_title');" \
        "el.focus();" \
        "el.value = #{text.to_json};" \
        "el.dispatchEvent(new Event('input', { bubbles: true }));"
      )
    end

    # keydownイベントをJS経由で発火するヘルパー
    def press_key(key)
      page.execute_script(
        "document.querySelector('#book_title')" \
        ".dispatchEvent(new KeyboardEvent('keydown', { key: #{key.to_json}, bubbles: true, cancelable: true }));"
      )
    end

    it 'ArrowDownで次の候補にフォーカスが移動する' do
      type_in_title('リーダブル')

      expect(page).to have_css('.title-autocomplete__item', wait: 10)
      press_key('ArrowDown')

      expect(page).to have_css('.title-autocomplete__item--active', wait: 5)
    end

    it 'Enterキーでフォーカスされている候補を選択できる' do
      type_in_title('リーダブル')

      expect(page).to have_css('.title-autocomplete__item', wait: 10)
      press_key('ArrowDown')
      press_key('Enter')

      expect(page).to have_field('タイトル', with: 'リーダブルコード', wait: 5)
    end

    it 'Escキーでドロップダウンが閉じる' do
      type_in_title('リーダブル')

      expect(page).to have_css('.title-autocomplete__list:not(.title-autocomplete__list--hidden)', wait: 10)
      press_key('Escape')

      expect(page).not_to have_css(
        '.title-autocomplete__list:not(.title-autocomplete__list--hidden)',
        wait: 3
      )
    end
  end

  describe '候補なし・エラー時のフォールバック' do
    it '候補がない場合はドロップダウンが表示されない' do
      stub_google_books(google_books_empty_response)
      stub_openbd_not_found

      title_input = find('#book_title')
      title_input.send_keys('存在しない書籍タイトル')

      sleep 1
      expect(page).not_to have_css(
        '.title-autocomplete__list:not(.title-autocomplete__list--hidden)'
      )
    end

    it 'APIが500応答でもドロップダウンが表示されず入力を継続できる' do
      stub_request(:get, /www\.googleapis\.com\/books\/v1\/volumes/)
        .to_return(status: 500)

      title_input = find('#book_title')
      title_input.send_keys('エラーテスト')

      sleep 1
      expect(page).not_to have_css(
        '.title-autocomplete__list:not(.title-autocomplete__list--hidden)'
      )
      expect(page).to have_field('タイトル', with: 'エラーテスト')
    end

    it 'ネットワーク失敗時（fetch reject）でもドロップダウンが表示されず入力を継続できる' do
      page.execute_script(<<~JS)
        window.__originalFetchForAutocomplete = window.fetch;
        window.fetch = () => Promise.reject(new Error('network-failure'));
      JS

      title_input = find('#book_title')
      title_input.send_keys('ネットワークエラー')

      sleep 1
      expect(page).not_to have_css(
        '.title-autocomplete__list:not(.title-autocomplete__list--hidden)'
      )
      expect(page).to have_field('タイトル', with: 'ネットワークエラー')
    ensure
      page.execute_script(<<~JS)
        if (window.__originalFetchForAutocomplete) {
          window.fetch = window.__originalFetchForAutocomplete;
          delete window.__originalFetchForAutocomplete;
        }
      JS
    end
  end

  describe '外部クリックでドロップダウンが閉じる' do
    before do
      stub_google_books(google_books_multi_response)
      stub_openbd_not_found
    end

    it '外部をクリックするとドロップダウンが閉じる' do
      title_input = find('#book_title')
      title_input.send_keys('リーダブル')

      expect(page).to have_css('.title-autocomplete__list:not(.title-autocomplete__list--hidden)', wait: 5)

      find('h1').click

      expect(page).not_to have_css(
        '.title-autocomplete__list:not(.title-autocomplete__list--hidden)',
        wait: 3
      )
    end
  end

  describe '既存のISBN検索フローに回帰がない' do
    it 'タイトル入力後のblurでは取得されず、情報取得ボタン押下で取得できる' do
      stub_google_books(google_books_single_response)
      stub_openbd_not_found

      page.execute_script(<<~JS)
        var el = document.getElementById('book_title');
        el.value = 'リーダブルコード';
        el.focus();
      JS
      find('#book_author').click

      expect(page).to have_field('著者', with: '', wait: 5)

      click_button '情報取得'

      expect(page).to have_field('著者', with: 'Dustin Boswell', wait: 10)
    end
  end
end
