# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'メモ検索機能', type: :system do
  let!(:user) { create(:user) }
  let!(:book) { create(:book, user: user, title: 'テスト書籍', status: :reading, deadline: Date.current + 5) }
  let!(:other_user) { create(:user) }
  let!(:other_book) { create(:book, user: other_user, title: '他ユーザーの本', status: :reading) }

  before do
    driven_by(:rack_test)
    rack_test_sign_in(user)
  end

  describe 'メモ検索フォームの表示' do
    it '一覧画面にメモ検索フォームが表示される' do
      visit books_path

      expect(page).to have_field('memo_keyword')
      expect(page).to have_button('メモを検索')
    end
  end

  describe 'メモ検索の実行' do
    let!(:matching_memo) { create(:book_memo, book: book, content: '重要なポイントです') }
    let!(:other_memo) { create(:book_memo, book: book, content: '別の内容') }

    it 'キーワードで検索するとメモ一覧が表示される' do
      visit books_path

      fill_in 'memo_keyword', with: '重要'
      click_button 'メモを検索'

      expect(page).to have_content('重要なポイントです')
      expect(page).not_to have_content('別の内容')
    end

    it 'メモ一覧にメモが属する本のタイトルが表示される' do
      visit books_path

      fill_in 'memo_keyword', with: '重要'
      click_button 'メモを検索'

      expect(page).to have_content(book.title)
    end

    it '検索結果が0件の場合は空メッセージが表示される' do
      visit books_path

      fill_in 'memo_keyword', with: '存在しないキーワード'
      click_button 'メモを検索'

      expect(page).to have_content('メモが見つかりません')
    end

    it 'クリアリンクをクリックすると本の一覧に戻る' do
      visit books_path(memo_keyword: '重要')

      expect(page).to have_css('#memo-search-clear')
      find('#memo-search-clear').click

      expect(current_path).to eq(books_path)
      expect(page).to have_content(book.title)
    end
  end

  describe 'アクセス制御' do
    let!(:other_memo) { create(:book_memo, book: other_book, content: '他ユーザーの重要メモ') }

    it '他ユーザーのメモは検索結果に含まれない' do
      visit books_path

      fill_in 'memo_keyword', with: '重要'
      click_button 'メモを検索'

      expect(page).not_to have_content('他ユーザーの重要メモ')
    end
  end
end
