# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '書籍管理', type: :system do
  let!(:user) { create(:user) }

  describe '書籍登録フロー' do
    before { login_as(user, scope: :user) }
    it '書籍登録フォームに入力して書籍を登録できる' do
      visit new_book_path

      fill_in 'タイトル', with: 'テスト駆動開発'
      fill_in '著者', with: 'Kent Beck'
      fill_in '総ページ数', with: '280'
      fill_in '読了対象ページ数', with: '280'
      fill_in '読了期限', with: (Date.current + 14).strftime('%Y-%m-%d')
      click_button '登録する'

      # 詳細画面にリダイレクト
      expect(page).to have_text('テスト駆動開発')
      expect(page).to have_text('Kent Beck')
    end

    it 'タイトルが空の場合はエラーが表示される' do
      visit new_book_path

      fill_in 'タイトル', with: ''
      fill_in '総ページ数', with: '100'
      fill_in '読了対象ページ数', with: '100'
      fill_in '読了期限', with: (Date.current + 14).strftime('%Y-%m-%d')
      click_button '登録する'

      expect(page).to have_text('タイトル')
      expect(page).to have_text('エラー')
    end
  end

  describe '書籍一覧表示' do
    before { login_as(user, scope: :user) }

    it '登録した書籍が一覧に表示される' do
      book = create(:book, user: user, title: '積読テスト本')

      visit books_path

      expect(page).to have_text(book.title)
    end

    it '書籍が0冊のときに Empty State が表示される' do
      visit books_path

      expect(page).to have_text('積読本はまだありません')
      expect(page).to have_text('最初の本を登録して始める')
    end

    it '書籍カードをクリックすると詳細画面へ遷移する' do
      book = create(:book, user: user, title: '詳細画面テスト本')

      visit books_path
      click_link book.title

      expect(page).to have_current_path(book_path(book))
      expect(page).to have_text(book.title)
    end
  end

  describe '書籍削除フロー（削除確認モーダル）', js: true do
    let!(:book) { create(:book, user: user, title: '削除テスト本') }

    before do
      # JS テストは Warden test_mode を使わず form で sign_in
      Warden.instance_variable_set(:@test_mode, false)
      sign_in_via_form(user)
      # Stimulus の初期化を待つため、book_path を事前にロードしておく
      visit book_path(book)
    end

    it '削除ボタンをクリックすると確認モーダルが表示される' do
      visit book_path(book)
      wait_for_stimulus

      page.execute_script("document.querySelector('[data-action=\"click->modal#open\"]').click()")

      expect(page).to have_text('本の削除')
      expect(page).to have_text(book.title)
      expect(page).to have_text('削除すると元に戻すことはできません')
    end

    it 'キャンセルボタンでモーダルが閉じる' do
      visit book_path(book)
      wait_for_stimulus

      page.execute_script("document.querySelector('[data-action=\"click->modal#open\"]').click()")
      expect(page).to have_text('本の削除')

      page.execute_script("document.querySelector('[data-action=\"click->modal#close\"]').click()")

      expect(page).to have_css('[data-modal-target="overlay"]', visible: :hidden)
    end

    it '削除確認後に書籍が削除されて一覧画面へ遷移する' do
      visit book_path(book)
      wait_for_stimulus

      page.execute_script("document.querySelector('[data-action=\"click->modal#open\"]').click()")

      # Wait for the deletion modal overlay to become visible
      expect(page).to have_css('[data-modal-target="overlay"]', visible: true)

      within('[data-modal-target="overlay"]') do
        click_button '削除する'
      end

      expect(page).to have_current_path(books_path)
      expect(page).not_to have_css('.book-card', text: book.title)
    end
  end
end
