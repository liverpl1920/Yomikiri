# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '積読登録画面でのタイトル検索結果フィードバック', type: :system, js: true do
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

  let(:google_books_no_isbn_response) do
    {
      'items' => [
        {
          'volumeInfo' => {
            'title' => 'ISBN なし本',
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

  let(:openbd_empty_response) do
    [ nil ].to_json
  end

  before do
    WebMock.reset!
    Warden.instance_variable_set(:@test_mode, false)
    sign_in_via_form(user)
    visit new_book_path
    wait_for_stimulus(identifier: 'book-form')
  end

  describe '全項目取得成功' do
    before do
      stub_request(:get, /www\.googleapis\.com\/books\/v1\/volumes/)
        .to_return(status: 200, body: google_books_full_response,
                   headers: { 'Content-Type' => 'application/json' })
      stub_request(:get, /api\.openbd\.jp\/v1\/get\?isbn=9784873115658/)
        .to_return(status: 200, body: openbd_response_with_cover,
                   headers: { 'Content-Type' => 'application/json' })
    end

    it '全取得成功メッセージが表示される' do
      # fill_inのSeleniumキー送信はCIでIMEタイミング問題が起きるためJSで直接blurをdispatchする
      page.execute_script(<<~JS)
        var el = document.getElementById('book_title');
        el.value = 'リーダブルコード';
        el.dispatchEvent(new Event('blur', { bubbles: true }));
      JS

      expect(page).to have_css('[data-book-form-target="titleStatus"]',
                               text: 'タイトル・著者・ページ数・書影をすべて取得しました。', wait: 20)
    end

    it '書影プレビュー画像が表示される' do
      page.execute_script(<<~JS)
        var el = document.getElementById('book_title');
        el.value = 'リーダブルコード';
        el.dispatchEvent(new Event('blur', { bubbles: true }));
      JS

      expect(page).to have_css('[data-book-form-target="coverPreview"] img', wait: 15)
    end
  end

  describe '部分取得（書影なし）' do
    before do
      stub_request(:get, /www\.googleapis\.com\/books\/v1\/volumes/)
        .to_return(status: 200, body: google_books_no_isbn_response,
                   headers: { 'Content-Type' => 'application/json' })
    end

    it '書影が取得できなかった旨のメッセージが表示される' do
      page.execute_script(<<~JS)
        var el = document.getElementById('book_title');
        el.value = 'ISBN なし本';
        el.dispatchEvent(new Event('blur', { bubbles: true }));
      JS

      expect(page).to have_css('[data-book-form-target="titleStatus"]',
                               text: '書籍情報を取得しましたが、書影は取得できませんでした。', wait: 20)
    end

    it '書影プレビューは表示されない' do
      page.execute_script(<<~JS)
        var el = document.getElementById('book_title');
        el.value = 'ISBN なし本';
        el.dispatchEvent(new Event('blur', { bubbles: true }));
      JS

      expect(page).not_to have_css('[data-book-form-target="coverPreview"] img', wait: 15)
    end
  end

  describe '取得失敗（書籍が見つからない）' do
    before do
      stub_request(:get, /www\.googleapis\.com\/books\/v1\/volumes/)
        .to_return(status: 200, body: google_books_empty_response,
                   headers: { 'Content-Type' => 'application/json' })
    end

    it '失敗メッセージが表示される' do
      page.execute_script(<<~JS)
        var el = document.getElementById('book_title');
        el.value = '存在しない本';
        el.dispatchEvent(new Event('blur', { bubbles: true }));
      JS

      expect(page).to have_css('[data-book-form-target="titleStatus"]',
                               text: 'タイトルから書籍情報を取得できませんでした。', wait: 15)
    end
  end
end
