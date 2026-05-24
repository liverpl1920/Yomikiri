# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'タイトル入力からのISBN・書影自動取得', type: :system, js: true do
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

  describe 'タイトル入力→自動取得成功' do
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

    it 'タイトルを入力してフォーカスを外すと書籍情報が自動入力される' do
      # JSで直接値を設定＋フォーカス（fill_inのSeniumキー送信はCIでIMEタイミング問題が起きるため）
      page.execute_script(<<~JS)
        var el = document.getElementById('book_title');
        el.value = 'リーダブルコード';
        el.focus();
      JS
      find('#book_author').click

      # fetch完了をステータスメッセージで確認してからフィールド値を検証する
      expect(page).to have_css('[data-book-form-target="titleStatus"]',
                               text: 'タイトル・著者・ページ数・書影をすべて取得しました。', wait: 20)
      expect(page).to have_field('著者', with: 'Dustin Boswell', wait: 5)
      expect(page).to have_field('総ページ数', with: '260', wait: 5)
    end

    it '自動取得成功時は成功メッセージが表示される' do
      page.execute_script(<<~JS)
        var el = document.getElementById('book_title');
        el.value = 'リーダブルコード';
        el.dispatchEvent(new Event('blur', { bubbles: true }));
      JS

      expect(page).to have_css('[data-book-form-target="titleStatus"]',
                               text: 'タイトル・著者・ページ数・書影をすべて取得しました。', wait: 20)
    end

    it '既に読んだページ数は自動取得後も保持される' do
      # Seleniumのfocus管理との干渉を避けるため、currentPageとtitleの両方をJSで設定する
      page.execute_script(<<~JS)
        var currentPageEl = document.querySelector('[data-book-form-target~="currentPage"]');
        if (currentPageEl) { currentPageEl.value = '42'; }
        var titleEl = document.getElementById('book_title');
        titleEl.value = 'リーダブルコード';
        titleEl.dispatchEvent(new Event('blur', { bubbles: true }));
      JS

      expect(page).to have_css('[data-book-form-target="titleStatus"]',
                               text: 'タイトル・著者・ページ数・書影をすべて取得しました。', wait: 20)
      expect(page).to have_field('既に読んだページ数', with: '42')
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

  describe 'タイトル入力→自動取得失敗' do
    before do
      stub_request(:get, /www\.googleapis\.com\/books\/v1\/volumes/)
        .to_return(status: 200, body: google_books_empty_response,
                   headers: { 'Content-Type' => 'application/json' })
    end

    it 'タイトル検索で結果がない場合、失敗メッセージが表示される' do
      # JSで直接値を設定してblurイベントを発火（fill_inのSeleniumキー送信はCIでIMEタイミング問題が起きるため）
      page.execute_script(<<~JS)
        var el = document.getElementById('book_title');
        el.value = '存在しない本のタイトル';
        el.dispatchEvent(new Event('blur', { bubbles: true }));
      JS

      expect(page).to have_css('[data-book-form-target="titleStatus"]',
                               text: 'タイトルから書籍情報を取得できませんでした。ISBNで検索してみてください。', wait: 20)
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
      fill_in 'タイトル', with: 'リーダブルコード'
      find('#book_author').click
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

  describe 'ISBNボタンによる書籍情報取得' do
    let(:openbd_not_found_response) { '[null]' }

    context '有効なISBNで書籍が見つかる場合' do
      before do
        stub_request(:get, /api\.openbd\.jp\/v1\/get\?isbn=9784873115658/)
          .to_return(status: 200, body: openbd_response_with_cover,
                     headers: { 'Content-Type' => 'application/json' })
      end

      it 'タイトル・著者・ページ数・書影が自動入力される' do
        page.execute_script(<<~JS)
          document.querySelector('[data-book-form-target="isbnInput"]').value = '9784873115658';
        JS
        find('[data-action="click->book-form#fetchByIsbn"]').click

        expect(page).to have_css('[data-book-form-target="isbnStatus"]',
                                 text: 'タイトル・著者・ページ数・書影をすべて取得しました。', wait: 20)
        expect(page).to have_field('タイトル', with: 'リーダブルコード', wait: 5)
        expect(page).to have_field('著者', with: 'Dustin Boswell', wait: 5)
        expect(page).to have_field('総ページ数', with: '260', wait: 5)
      end

      it 'Enterキーで取得ボタンと同じ動作をする' do
        isbn_input = find('[data-book-form-target="isbnInput"]')
        page.execute_script(
          "document.querySelector('[data-book-form-target=\"isbnInput\"]').value = '9784873115658';"
        )
        isbn_input.send_keys(:return)

        expect(page).to have_css('[data-book-form-target="isbnStatus"]',
                                 text: 'タイトル・著者・ページ数・書影をすべて取得しました。', wait: 20)
      end
    end

    context '有効なISBNで書籍が見つからない場合' do
      before do
        stub_request(:get, /api\.openbd\.jp\/v1\/get\?isbn=9784000000000/)
          .to_return(status: 200, body: openbd_not_found_response,
                     headers: { 'Content-Type' => 'application/json' })
      end

      it 'ISBN未発見メッセージが表示されフォームは汚染されない' do
        page.execute_script(<<~JS)
          document.querySelector('[data-book-form-target="isbnInput"]').value = '9784000000000';
        JS
        find('[data-action="click->book-form#fetchByIsbn"]').click

        expect(page).to have_css('[data-book-form-target="isbnStatus"]',
                                 text: 'ISBNに一致する書籍が見つかりませんでした。', wait: 20)
        expect(page).to have_field('タイトル', with: '', wait: 5)
        expect(page).to have_field('著者', with: '', wait: 5)
      end
    end

    context '無効なISBNを入力した場合' do
      it 'バリデーションエラーメッセージが表示されサーバーリクエストを行わない' do
        page.execute_script(<<~JS)
          document.querySelector('[data-book-form-target="isbnInput"]').value = '12345';
        JS
        find('[data-action="click->book-form#fetchByIsbn"]').click

        expect(page).to have_css('[data-book-form-target="isbnStatus"]',
                                 text: 'ISBNは13桁の数字（ISBN-13）または10桁の数字・末尾X（ISBN-10）で入力してください。', wait: 5)
        expect(page).to have_field('タイトル', with: '', wait: 3)
      end
    end
  end

  def wait_for_book_form_controller
    wait_for_stimulus
  end
end
