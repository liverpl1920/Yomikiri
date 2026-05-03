# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'タイトル入力からのISBN・書影自動取得', type: :system, js: true do
  let!(:user) { create(:user) }

  let(:openbd_response_with_cover) do
    [ {
      'summary' => {
        'isbn' => '9784873115658',
        'title' => 'リーダブルコード',
        'author' => 'Dustin Boswell'
      },
      'onix' => {
        'DescriptiveDetail' => {
          'Extent' => [
            { 'ExtentType' => '11', 'ExtentValue' => '260' }
          ]
        }
      }
    } ].to_json
  end

  let(:google_books_response_with_isbn) do
    {
      'items' => [
        {
          'volumeInfo' => {
            'title' => 'リーダブルコード',
            'authors' => [ 'Dustin Boswell' ],
            'pageCount' => 260,
            'industryIdentifiers' => [
              { 'type' => 'ISBN_13', 'identifier' => '9784873115658' }
            ]
          }
        }
      ]
    }.to_json
  end

  let(:google_books_response_no_isbn) do
    {
      'items' => [
        {
          'volumeInfo' => {
            'title' => 'ある本',
            'authors' => [ '著者名' ],
            'pageCount' => 100,
            'industryIdentifiers' => []
          }
        }
      ]
    }.to_json
  end

  let(:google_books_empty_response) do
    { 'items' => [] }.to_json
  end

  before do
    WebMock.reset!
    sign_in_via_form(user)
    visit new_book_path
    wait_for_stimulus
  end

  describe 'タイトル入力→自動取得成功' do
    before do
      stub_request(:get, /www\.googleapis\.com\/books\/v1\/volumes/)
        .to_return(status: 200, body: google_books_response_with_isbn,
                   headers: { 'Content-Type' => 'application/json' })
      stub_request(:get, /api\.openbd\.jp\/v1\/get\?isbn=/)
        .to_return(status: 200, body: openbd_response_with_cover,
                   headers: { 'Content-Type' => 'application/json' })
    end

    it 'タイトルを入力してフォーカスを外すと書籍情報が自動入力される' do
      fill_in 'タイトル', with: 'リーダブルコード'
      find('#book_author').click

      expect(page).to have_field('著者', with: 'Dustin Boswell', wait: 5)
      expect(page).to have_field('総ページ数', with: '260', wait: 5)
      expect(page).to have_field('書影URL', with: 'https://cover.openbd.jp/9784873115658.jpg', wait: 5)
    end

    it '自動取得成功時はISBNフォールバックセクションが非表示のまま' do
      fill_in 'タイトル', with: 'リーダブルコード'
      find('#book_author').click

      expect(page).to have_field('著者', with: 'Dustin Boswell', wait: 5)
      expect(page).not_to have_css('.book-form__isbn-section:not(.book-form__isbn-section--hidden)', wait: 1)
    end

    it '自動取得成功時は成功メッセージが表示される' do
      fill_in 'タイトル', with: 'リーダブルコード'
      find('#book_author').click

      expect(page).to have_css('[data-book-form-target="titleStatus"]', text: '書影と書籍情報を自動入力しました。', wait: 5)
    end
  end

  describe 'タイトル入力→自動取得失敗→ISBNフォールバック表示' do
    before do
      stub_request(:get, /www\.googleapis\.com\/books\/v1\/volumes/)
        .to_return(status: 200, body: google_books_empty_response,
                   headers: { 'Content-Type' => 'application/json' })
    end

    it 'タイトル検索で結果がない場合、ISBNフォールバックセクションが表示される' do
      fill_in 'タイトル', with: '存在しない本のタイトル'
      find('#book_author').click

      expect(page).to have_css('.book-form__isbn-section:not(.book-form__isbn-section--hidden)', wait: 5)
    end

    it '取得失敗時はステータスメッセージが表示される' do
      fill_in 'タイトル', with: '存在しない本のタイトル'
      find('#book_author').click

      expect(page).to have_css('[data-book-form-target="titleStatus"]',
                               text: /取得できませんでした|ISBNが分かる場合/, wait: 5)
    end
  end

  describe 'ISBN手動入力→書影取得' do
    before do
      stub_request(:get, /www\.googleapis\.com\/books\/v1\/volumes/)
        .to_return(status: 200, body: google_books_empty_response,
                   headers: { 'Content-Type' => 'application/json' })
      stub_request(:get, /api\.openbd\.jp\/v1\/get\?isbn=9784873115658/)
        .to_return(status: 200, body: openbd_response_with_cover,
                   headers: { 'Content-Type' => 'application/json' })
    end

    it 'ISBNを入力して「取得する」を押すと書影URLが設定される' do
      fill_in 'タイトル', with: '存在しない本のタイトル'
      find('#book_author').click

      expect(page).to have_css('.book-form__isbn-section:not(.book-form__isbn-section--hidden)', wait: 5)

      find('[data-book-form-target="isbn"]').fill_in with: '9784873115658'
      find('[data-action="click->book-form#fetchByIsbn"]').click

      expect(page).to have_field('書影URL', with: 'https://cover.openbd.jp/9784873115658.jpg', wait: 5)
      expect(page).to have_css('[data-book-form-target="isbnStatus"]', text: '書影を取得しました。', wait: 5)
    end
  end

  describe 'ISBN未入力での書籍登録' do
    before do
      stub_request(:get, /www\.googleapis\.com\/books\/v1\/volumes/)
        .to_return(status: 200, body: google_books_empty_response,
                   headers: { 'Content-Type' => 'application/json' })
    end

    it 'タイトルと必須項目のみで書籍を登録できる' do
      fill_in 'タイトル', with: '手動入力テスト本'
      fill_in '総ページ数', with: '200'
      fill_in '読了対象ページ数', with: '200'
      deadline = (Date.current + 30.days).strftime('%Y-%m-%d')
      page.execute_script("document.getElementById('book_deadline').value = '#{deadline}'")
      page.execute_script("document.getElementById('book_deadline').dispatchEvent(new Event('change'))")

      click_button '登録する'

      expect(page).to have_text('手動入力テスト本', wait: 5)
    end
  end

  def wait_for_book_form_controller
    wait_for_stimulus
  end
end
