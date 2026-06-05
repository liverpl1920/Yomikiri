# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '積読登録画面での書籍情報個別取得', type: :system, js: true do
  let!(:user) { create(:user) }

  let(:google_books_full_response) do
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

  let(:openbd_response_with_cover) do
    [ {
      'summary' => {
        'isbn' => '9784873115658',
        'title' => 'リーダブルコード',
        'author' => 'Dustin Boswell',
        'cover' => 'https://cover.openbd.jp/9784873115658.jpg'
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

  before do
    WebMock.reset!
    Warden.instance_variable_set(:@test_mode, false)
    if page.driver.respond_to?(:browser) && page.driver.browser.respond_to?(:manage)
      page.driver.browser.manage.window.resize_to(1280, 1024)
    end
    sign_in_via_form(user)
    visit new_book_path
    wait_for_stimulus(identifier: 'book-form')
    wait_for_stimulus(identifier: 'title-autocomplete')

    # APIリクエストをスタブ化
    stub_request(:get, /www\.googleapis\.com\/books\/v1\/volumes/)
      .to_return(status: 200, body: google_books_full_response,
                 headers: { 'Content-Type' => 'application/json' })
    stub_request(:get, /api\.openbd\.jp\/v1\/get\?isbn=9784873115658/)
      .to_return(status: 200, body: openbd_response_with_cover,
                 headers: { 'Content-Type' => 'application/json' })
  end

  after do
    if page.driver.respond_to?(:browser)
      logs = page.driver.browser.logs.get(:browser)
      puts "BROWSER LOGS: #{logs.map(&:message).join("\n")}"
    end
    visit 'about:blank'
    WebMock.reset!
  end

  def click_complement_button(field)
    sleep 0.2
    page.execute_script(<<~JS)
      var btn = document.querySelector("button[data-action*='book-form#fetchSingleField'][data-field='#{field}']");
      if (btn) { btn.click(); }
    JS
  end

  describe '個別取得機能' do
    context 'タイトルが空の場合' do
      it '警告メッセージが表示され、APIは呼び出されない' do
        click_complement_button('author')

        expect(page).to have_css('[data-book-form-target="titleStatus"]',
                                 text: 'タイトルを入力してください。', wait: 10)
        expect(a_request(:get, /www\.googleapis\.com\/books\/v1\/volumes/)).not_to have_been_made
      end
    end

    context 'タイトルが入力されている場合' do
      before do
        # JavaScriptでタイトルを直接設定し、オートコンプリートによる非同期APIリクエストを発生させずに進める
        page.execute_script("document.getElementById('book_title').value = 'リーダブルコード'")
      end

      it '特定の項目（著者）だけを個別に補完できる' do
        click_complement_button('author')

        # 著者が自動入力され、ステータスが表示されること
        expect(page).to have_field('著者', with: 'Dustin Boswell', wait: 10)
        expect(page).to have_css('[data-book-form-target="titleStatus"]', text: '著者を取得しました。', wait: 10)

        # APIリクエストが純粋に1回送信されたことを検証
        expect(a_request(:get, /www\.googleapis\.com\/books\/v1\/volumes/)).to have_been_made.once

        # 他の項目は空のままであること
        expect(page).to have_field('ページ数', with: '')
      end

      it 'キャッシュ機能により、2つ目の項目補完時はAPIリクエストが再送されない' do
        # 1. 著者補完（APIリクエストが発生）
        click_complement_button('author')
        expect(page).to have_field('著者', with: 'Dustin Boswell', wait: 10)

        # Google Books API が1回呼び出されていることを検証
        expect(a_request(:get, /www\.googleapis\.com\/books\/v1\/volumes/)).to have_been_made.once

        # 2. ページ数補完（キャッシュを利用するためAPIリクエストは発生しない）
        click_complement_button('pages')
        expect(page).to have_field('ページ数', with: '260', wait: 10)
        expect(page).to have_css('[data-book-form-target="titleStatus"]', text: 'ページ数を取得しました。', wait: 10)

        # API呼び出し回数が1回のままであることを検証
        expect(a_request(:get, /www\.googleapis\.com\/books\/v1\/volumes/)).to have_been_made.once
      end

      it 'ページ数補完の成功時、今日のノルマが自動更新されること' do
        # 読了期限を入力しておく
        fill_in '読了期限', with: (Date.current + 7.days).to_s

        click_complement_button('pages')
        expect(page).to have_field('ページ数', with: '260', wait: 10)

        # 今日のノルマ表示が更新されていること
        expect(page).to have_css('.quota-preview__number', text: /\A[0-9]+\z/)
      end

      it '書影画像補完の成功時、書影プレビューが表示され、手動のファイル選択がクリアされること' do
        # テスト用の画像を添付する
        attach_file('書影画像', Rails.root.join('spec/fixtures/files/test_cover.png'))

        # WebMock で openbd api は stub されているため、画像URLが返る
        click_complement_button('cover')

        # 書影プレビュー（imgタグ）が表示されていること
        expect(page).to have_css('[data-book-form-target="coverPreview"] img', wait: 10)
        expect(page).to have_css('[data-book-form-target="titleStatus"]', text: '書影を取得しました。', wait: 10)

        # ファイル選択フォームの値が空であることを確認
        file_input_val = page.execute_script("return document.getElementById('book_cover_image').value")
        expect(file_input_val).to eq('')
      end
    end
  end
end
