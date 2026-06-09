# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '重複タイトル登録時の警告と再読記録', type: :system, js: true do
  let!(:user) { create(:user) }
  let!(:book1) { create(:book, user: user, title: 'リーダブルコード', pages: 300, current_page: 300, status: :completed) }

  let(:google_books_empty_response) { { 'items' => [] }.to_json }
  let(:openbd_not_found_response) { [ nil ].to_json }

  def stub_google_books
    stub_request(:get, /www\.googleapis\.com\/books\/v1\/volumes/)
      .to_return(status: 200, body: google_books_empty_response,
                 headers: { 'Content-Type' => 'application/json' })
  end

  def stub_openbd_not_found
    stub_request(:get, /api\.openbd\.jp\/v1\/get/)
      .to_return(status: 200, body: openbd_not_found_response,
                 headers: { 'Content-Type' => 'application/json' })
  end

  # 直接入力して input イベントを発火させるヘルパー
  def type_in_title(text)
    page.execute_script(
      "const el = document.querySelector('#book_title');" \
      "el.focus();" \
      "el.value = #{text.to_json};" \
      "el.dispatchEvent(new Event('input', { bubbles: true }));"
    )
  end

  # type="date" フィールドに安全に値を設定するヘルパー
  def set_date_field(id, date_str)
    page.execute_script(
      "const el = document.getElementById(#{id.to_json});" \
      "el.focus();" \
      "el.value = #{date_str.to_json};" \
      "el.dispatchEvent(new Event('change', { bubbles: true }));"
    )
  end

  before do
    WebMock.reset!
    stub_google_books
    stub_openbd_not_found
    Warden.instance_variable_set(:@test_mode, false)
    sign_in_via_form(user)
  end

  describe '新規登録時の重複警告' do
    before do
      visit new_book_path
      wait_for_stimulus(identifier: 'book-form')
      wait_for_stimulus(identifier: 'title-autocomplete')
    end

    it '重複するタイトルを入力した際、警告が表示され、confirmを拒否すると登録されず、confirmを承諾すると登録されて詳細画面に遷移すること' do
      # 正常なタイトルを入力
      type_in_title('新しい本')
      fill_in 'ページ数', with: 300
      set_date_field('book_deadline', (Date.current + 7).to_s)
      expect(page).not_to have_text('同じタイトルの本が既に')

      # 重複タイトルを入力
      type_in_title('リーダブルコード')
      expect(page).to have_text('※同じタイトルの本が既に1冊登録されています。')

      # オートコンプリートを閉じるためにページ数フィールドをクリック
      find('#book_pages').click

      # confirmをキャンセル（false）を返すようにスタブ
      page.execute_script(
        "window.confirmCalled = false;" \
        "window.confirmMessage = '';" \
        "window.confirm = (msg) => { window.confirmCalled = true; window.confirmMessage = msg; return false; };"
      )

      # 送信して confirm をキャンセル
      click_button '登録する'

      # confirm が正しく呼び出され、登録されず、新規画面のままであること
      expect(page.evaluate_script("window.confirmCalled")).to be true
      expect(page.evaluate_script("window.confirmMessage")).to eq('同じタイトルの本が既に登録されています。このまま登録しますか？')
      expect(page).to have_text('※同じタイトルの本が既に1冊登録されています。')

      # confirmを承諾（true）を返すようにスタブ
      page.execute_script(
        "window.confirm = (msg) => { return true; };"
      )

      # 今度は承諾して送信
      click_button '登録する'

      # 詳細画面へ遷移
      expect(page).to have_current_path(/\/books\/\d+/)
      new_book = Book.last
      expect(page).to have_current_path(book_path(new_book))

      # タイトルに(2回目)が表示されること
      expect(page).to have_text('リーダブルコード(2回目)')

      # 前回リンクが表示され、クリックすると1回目に遷移すること
      expect(page).to have_link('前回（1回目）の読書記録はこちら')
      click_link '前回（1回目）の読書記録はこちら'

      expect(page).to have_current_path(book_path(book1))
      expect(page).to have_text('リーダブルコード')
      expect(page).not_to have_text('リーダブルコード(1回目)')
      expect(page).not_to have_link('前回（0回目）')
    end
  end

  describe '一覧画面での表示' do
    let!(:book2) { create(:book, user: user, title: 'リーダブルコード', pages: 300, current_page: 0, deadline: Date.current + 7) }

    it '再読記録の回数が一覧画面でも表示されること' do
      visit books_path

      expect(page).to have_text('リーダブルコード')
      expect(page).to have_text('リーダブルコード(2回目)')
    end
  end
end
