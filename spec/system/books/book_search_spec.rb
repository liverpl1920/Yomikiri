# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '書籍検索による自動補完', type: :system, js: true do
  let!(:user) { create(:user) }

  let(:openbd_response) do
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

  let(:google_books_response) do
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

  before do
    WebMock.reset!
    stub_request(:get, /api\.openbd\.jp\/v1\/get\?isbn=/)
      .to_return(status: 200, body: openbd_response, headers: { 'Content-Type' => 'application/json' })
    stub_request(:get, /www\.googleapis\.com\/books\/v1\/volumes/)
      .to_return(status: 200, body: google_books_response, headers: { 'Content-Type' => 'application/json' })
    sign_in_via_form(user)
    visit new_book_path
    wait_for_book_search_controller
  end

  describe '書籍名検索による候補選択' do
    it '候補一覧から選択してフォームに値を補完できる' do
      fill_in 'ISBNまたは書籍名から自動入力', with: 'リーダブルコード'
      find('.book-search__button').click

      expect(page).to have_text('件の候補が見つかりました')
      expect(page).to have_css('.book-search__result-button', count: 2)
      find('.book-search__result-button', text: 'リーダブルコード / Dustin Boswell').click

      expect(page).to have_field('タイトル', with: 'リーダブルコード')
      expect(page).to have_field('著者', with: 'Dustin Boswell')
      expect(page).to have_field('総ページ数', with: '260')
      expect(page).not_to have_css('.book-search__result-button')
    end
  end

  def wait_for_book_search_controller
    connected = false
    start = Time.now
    until Time.now - start > 10
      connected = page.evaluate_script(<<~JS)
        (() => {
          if (!window.Stimulus) return false
          const controller = window.Stimulus.controllers.find(c => c.identifier === 'book-search')
          return !!(controller && controller.hasQueryTarget && controller.hasStatusTarget && controller.hasResultsTarget)
        })()
      JS
      break if connected

      sleep 0.1
    end
    expect(connected).to be(true), 'book-search controller did not connect within 10 seconds'
  end
end
