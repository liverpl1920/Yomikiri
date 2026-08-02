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
      select '技術書', from: '種類'
      fill_in 'ページ数', with: '280', exact: true
      fill_in '読了期限', with: (Date.current + 14).strftime('%Y-%m-%d')
      click_button '登録する'

      # 詳細画面にリダイレクト
      expect(page).to have_text('テスト駆動開発')
      expect(page).to have_text('Kent Beck')
      expect(page).to have_text('技術書')
    end

    it 'タイトルが空の場合はエラーが表示される' do
      visit new_book_path

      fill_in 'タイトル', with: ''
      fill_in 'ページ数', with: '100', exact: true
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

      page.execute_script("document.querySelector('[data-modal-target=\"overlay\"] button[type=\"submit\"]').click()")

      expect(page).to have_current_path(books_path)
      expect(page).not_to have_css('.book-card', text: book.title)
    end
  end

  describe '書籍コピー再登録フロー' do
    before { login_as(user, scope: :user) }

    it '詳細画面の「この本をもう一度読む」リンクから値が引き継がれた新規登録画面に遷移し、新しく登録できること' do
      original_book = create(:book, user: user, title: 'コピー元の本', author: '著者A', genre: 'IT', category: :technical, pages: 300, status: :completed)

      visit book_path(original_book)
      click_link 'この本をもう一度読む'

      expect(page).to have_current_path(new_book_path(copy_from_id: original_book.id))
      expect(find_field('タイトル').value).to eq('【2度目】コピー元の本')
      expect(find_field('著者').value).to eq('著者A')
      expect(find_field('ジャンル').value).to eq('IT')
      expect(find_field('種類').value).to eq('technical')
      expect(find_field('ページ数').value).to eq('300')

      fill_in '読了期限', with: (Date.current + 7).strftime('%Y-%m-%d')
      click_button '登録する'

      expect(page).to have_text('【2度目】コピー元の本')
      expect(page).to have_text('著者A')
      expect(page).to have_text('技術書')
      expect(page).to have_text('未読')
    end
  end
end
