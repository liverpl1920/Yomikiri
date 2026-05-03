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
    stub_request(:get, /api\.openbd\.jp\/v1\/get\?isbn=9784873115658/)
      .to_return(status: 200, body: openbd_response, headers: { 'Content-Type' => 'application/json' })
    stub_request(:get, /www\.googleapis\.com\/books\/v1\/volumes/)
      .to_return(status: 200, body: google_books_response, headers: { 'Content-Type' => 'application/json' })
    sign_in_via_form(user)
    visit new_book_path
    wait_for_stimulus
  end

  describe 'ISBN検索による自動補完' do
    it 'ISBNを入力して検索するとフォームに値が補完される' do
      fill_in 'ISBNまたは書籍名から自動入力', with: '9784873115658'
      click_button '検索'

      expect(page).to have_field('タイトル', with: 'リーダブルコード')
      expect(page).to have_field('著者', with: 'Dustin Boswell')
      expect(page).to have_field('総ページ数', with: '260')
    end

    it '自動補完後にステータスメッセージが表示される' do
      fill_in 'ISBNまたは書籍名から自動入力', with: '9784873115658'
      click_button '検索'

      # フォーム補完完了を待ってからステータスを確認
      expect(page).to have_field('タイトル', with: 'リーダブルコード')
      expect(find('.book-search__status').text).to eq('書籍情報を自動入力しました')
    end

    it 'Enterキーでも検索できる' do
      fill_in 'ISBNまたは書籍名から自動入力', with: '9784873115658'
      find('[data-book-search-target="query"]').send_keys(:return)

      expect(page).to have_field('タイトル', with: 'リーダブルコード')
    end
  end

  describe '書籍名検索による候補選択' do
    it '書籍名を入力して検索すると候補一覧が表示される' do
      fill_in 'ISBNまたは書籍名から自動入力', with: 'リーダブルコード'
      click_button '検索'

      expect(page).to have_text('件の候補が見つかりました')
      expect(page).to have_css('.book-search__result-item', count: 2)
    end

    it '候補を選択するとフォームに値が補完される' do
      fill_in 'ISBNまたは書籍名から自動入力', with: 'リーダブルコード'
      click_button '検索'

      find('.book-search__result-item', text: 'リーダブルコード / Dustin Boswell').click

      expect(page).to have_field('タイトル', with: 'リーダブルコード')
      expect(page).to have_field('著者', with: 'Dustin Boswell')
      expect(page).to have_field('総ページ数', with: '260')
    end

    it '候補選択後はリストが非表示になる' do
      fill_in 'ISBNまたは書籍名から自動入力', with: 'リーダブルコード'
      click_button '検索'
      find('.book-search__result-item', text: 'リーダブルコード / Dustin Boswell').click

      expect(page).not_to have_css('.book-search__result-item')
    end
  end
end
