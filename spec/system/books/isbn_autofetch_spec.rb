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
    wait_for_stimulus
    # book-form コントローラーの接続を確実に待つ（wait_for_stimulusは任意コントローラーが接続された時点で返るため）
    start = Time.now
    until Time.now - start > 10
      break if page.evaluate_script("window.Stimulus && window.Stimulus.controllers.some(c => c.identifier === 'book-form')")

      sleep 0.1
    end
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
      fill_in 'タイトル', with: 'リーダブルコード'
      find('#book_author').click

      expect(page).to have_css('[data-book-form-target="titleStatus"]',
                               text: 'タイトル・著者・ページ数・書影をすべて取得しました。', wait: 20)
    end

    it '既に読んだページ数は自動取得後も保持される' do
      fill_in '既に読んだページ数', with: '42'
      fill_in 'タイトル', with: 'リーダブルコード'
      find('#book_author').click

      expect(page).to have_css('[data-book-form-target="titleStatus"]',
                               text: 'タイトル・著者・ページ数・書影をすべて取得しました。', wait: 5)
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

  def wait_for_book_form_controller
    wait_for_stimulus
  end
end
