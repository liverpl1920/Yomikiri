# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '情報取得ボタンによるISBN・書影取得', type: :system, js: true do
  let!(:user) { create(:user) }

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
            ],
            'imageLinks' => {
              'thumbnail' => 'http://books.google.com/books/content?id=test&zoom=1'
            }
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

  let(:openbd_response_with_cover) do
    [ {
      'summary' => {
        'isbn' => '9784873115658',
        'title' => 'リーダブルコード',
        'author' => 'Dustin Boswell',
        'genre' => 'プログラミング',
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
    sign_in_via_form(user)
    visit new_book_path
    wait_for_stimulus(identifier: 'book-form')
  end

  def fetch_by_button(title)
    page.execute_script(<<~JS)
      var el = document.getElementById('book_title');
      el.value = #{title.to_json};
      var btn = document.querySelector('button[data-action*="book-form#fetchByTitle"]');
      if (btn) { btn.click(); }
    JS
  end

  describe '情報取得ボタン押下で取得成功' do
    before do
      stub_request(:get, /www\.googleapis\.com\/books\/v1\/volumes/)
        .to_return(status: 200, body: google_books_response_with_isbn,
                   headers: { 'Content-Type' => 'application/json' })
      stub_request(:get, /api\.openbd\.jp\/v1\/get\?isbn=9784873115658/)
        .to_return(status: 200, body: openbd_response_with_cover,
                   headers: { 'Content-Type' => 'application/json' })
    end

    it '初期表示で不要な入力欄が表示されない' do
      expect(page).not_to have_field('ISBNまたは書籍名から自動入力')
      expect(page).not_to have_field('書影URL')
    end

    it 'タイトル入力して情報取得ボタンを押すと書籍情報が入力される' do
      fetch_by_button('リーダブルコード')

      # fetch完了をステータスメッセージで確認してからフィールド値を検証する
      expect(page).to have_css('[data-book-form-target="titleStatus"]',
                               text: 'タイトル・著者・ページ数・書影をすべて取得しました。', wait: 20)
      expect(page).to have_field('著者', with: 'Dustin Boswell', wait: 5)
      expect(page).to have_field('総ページ数', with: '260', wait: 5)
    end

    it 'タイトル入力してblurしても情報取得は実行されない' do
      page.execute_script(<<~JS)
        var el = document.getElementById('book_title');
        el.value = 'リーダブルコード';
        el.dispatchEvent(new Event('blur', { bubbles: true }));
      JS

      expect(page).not_to have_css('[data-book-form-target="titleStatus"]', text: '取得', wait: 2)
      expect(page).to have_field('著者', with: '')
    end

    it '手動取得成功時は成功メッセージが表示される' do
      fetch_by_button('リーダブルコード')

      expect(page).to have_css('[data-book-form-target="titleStatus"]',
                               text: 'タイトル・著者・ページ数・書影をすべて取得しました。', wait: 20)
    end

    it '既に読んだページ数は手動取得後も保持される' do
      # Seleniumのfocus管理との干渉を避けるため、currentPageとtitleの両方をJSで設定する
      page.execute_script(<<~JS)
        var currentPageEl = document.querySelector('[data-book-form-target~="currentPage"]');
        if (currentPageEl) { currentPageEl.value = '42'; }
      JS

      fetch_by_button('リーダブルコード')

      expect(page).to have_css('[data-book-form-target="titleStatus"]',
                               text: 'タイトル・著者・ページ数・書影をすべて取得しました。', wait: 20)
      expect(page).to have_field('既に読んだページ数', with: '42')
    end

    it '読了対象ページ数は手動入力済みなら手動取得後も保持される' do
      fill_in '読了対象ページ数', with: '123'

      fetch_by_button('リーダブルコード')

      expect(page).to have_css('[data-book-form-target="titleStatus"]',
                               text: 'タイトル・著者・ページ数・書影をすべて取得しました。', wait: 20)
      expect(page).to have_field('読了対象ページ数', with: '123')
    end

    it '既に読んだページ数を考慮してノルマプレビューを表示する' do
      fill_in '読了対象ページ数', with: '260'
      deadline = (Date.today + 9.days).strftime('%Y-%m-%d')
      page.execute_script("document.getElementById('book_deadline').value = '#{deadline}'")
      page.execute_script("document.getElementById('book_deadline').dispatchEvent(new Event('change'))")
      fill_in '既に読んだページ数', with: '80'
      page.execute_script("document.querySelector('[data-book-form-target~=\"currentPage\"]').dispatchEvent(new Event('input'))")

      expect(page).to have_css('.quota-preview__number', text: '18')
      expect(page).to have_css('.quota-preview__note', text: '残り 10 日で読み切るには、1日 18 ページ必要です')
    end
  end

  describe '情報取得ボタン押下で取得失敗' do
    before do
      stub_request(:get, /www\.googleapis\.com\/books\/v1\/volumes/)
        .to_return(status: 200, body: google_books_empty_response,
                   headers: { 'Content-Type' => 'application/json' })
    end

    it 'タイトル検索で結果がない場合、失敗メッセージが表示される' do
      fetch_by_button('存在しない本のタイトル')

      expect(page).to have_css('[data-book-form-target="titleStatus"]',
                               text: 'タイトルから書籍情報を取得できませんでした。', wait: 20)
    end
  end

  describe '書影URL付き書籍の登録' do
    before do
      stub_request(:get, /www\.googleapis\.com\/books\/v1\/volumes/)
        .to_return(status: 200, body: google_books_response_with_isbn,
                   headers: { 'Content-Type' => 'application/json' })
      stub_request(:get, /api\.openbd\.jp\/v1\/get\?isbn=9784873115658/)
        .to_return(status: 200, body: openbd_response_with_cover,
                   headers: { 'Content-Type' => 'application/json' })
    end

    it '書影URLが書籍に保存される' do
      fetch_by_button('リーダブルコード')
      expect(page).to have_css('[data-book-form-target="titleStatus"]',
                               text: 'タイトル・著者・ページ数・書影をすべて取得しました。', wait: 5)

      fill_in '総ページ数', with: '260'
      fill_in '読了対象ページ数', with: '260'
      deadline = (Date.current + 30.days).strftime('%Y-%m-%d')
      page.execute_script("document.getElementById('book_deadline').value = '#{deadline}'")
      page.execute_script("document.getElementById('book_deadline').dispatchEvent(new Event('change'))")

      click_button '登録する'

      expect(page).to have_text('リーダブルコード', wait: 5)
      expect(Book.order(:id).last.cover_image_url).to eq('https://cover.openbd.jp/9784873115658.jpg')
    end
  end

  describe '情報取得後にファイルをアップロードして登録' do
    before do
      stub_request(:get, /www\.googleapis\.com\/books\/v1\/volumes/)
        .to_return(status: 200, body: google_books_response_with_isbn,
                   headers: { 'Content-Type' => 'application/json' })
      stub_request(:get, /api\.openbd\.jp\/v1\/get\?isbn=9784873115658/)
        .to_return(status: 200, body: openbd_response_with_cover,
                   headers: { 'Content-Type' => 'application/json' })
    end

    it '情報取得後にファイルを選択してもcover_image_urlバリデーションエラーが発生しない' do
      # 情報取得ボタンでcover_image_urlをセット
      fetch_by_button('リーダブルコード')
      expect(page).to have_css('[data-book-form-target="titleStatus"]',
                               text: 'タイトル・著者・ページ数・書影をすべて取得しました。', wait: 20)

      # cover_image_url hidden フィールドにURLが入っていることを確認
      cover_url_value = page.evaluate_script("document.getElementById('book_cover_image_url').value")
      expect(cover_url_value).not_to be_empty

      # ファイルを選択すると cover_image_url がクリアされること
      attach_file('book[cover_image]', Rails.root.join('spec/fixtures/files/test_cover.png').to_s,
                  make_visible: true)

      cover_url_after = page.evaluate_script("document.getElementById('book_cover_image_url').value")
      expect(cover_url_after).to eq('')
    end
  end
end
