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
    it '一覧画面の検索フォームにメモ内容フィールドが表示される' do
      visit books_path

      expect(page).to have_field('memo_keyword')
      expect(page).to have_field('メモ内容')
    end
  end

  describe 'メモ検索の実行' do
    let!(:matching_memo) { create(:book_memo, book: book, content: '重要なポイントです') }
    let!(:no_match_book) do
      create(:book, user: user, title: 'マッチしない本', status: :unread, deadline: Date.current + 10)
    end

    it '検索フォームのメモ内容欄にキーワードを入力して検索するとメモ自体が表示される' do
      visit books_path

      fill_in 'memo_keyword', with: '重要'
      find('#books-search-submit').click

      expect(page).to have_content('重要なポイントです')
      expect(page).to have_link('本の該当箇所へ', href: book_path(book, anchor: ActionView::RecordIdentifier.dom_id(matching_memo)))
    end

    it 'マッチしないメモは表示されない' do
      create(:book_memo, book: book, content: '関係のないメモ内容')
      visit books_path

      fill_in 'memo_keyword', with: '重要'
      find('#books-search-submit').click

      expect(page).not_to have_content('関係のないメモ内容')
    end

    it '検索結果が0件の場合は条件に一致する本やメモがないメッセージが表示される' do
      visit books_path

      fill_in 'memo_keyword', with: '存在しないキーワード'
      find('#books-search-submit').click

      expect(page).to have_content('条件に一致する本やメモがありません')
    end

    it 'クリアリンクをクリックすると本の一覧に戻る' do
      visit books_path(memo_keyword: '重要')

      click_link 'クリア'

      expect(current_path).to eq(books_path)
      expect(page).to have_content(book.title)
    end
  end

  describe 'アクセス制御' do
    let!(:other_memo) { create(:book_memo, book: other_book, content: '他ユーザーの重要メモ') }

    it '他ユーザー of メモは検索結果に表示されない' do
      visit books_path

      fill_in 'memo_keyword', with: '重要'
      find('#books-search-submit').click

      expect(page).not_to have_content('他ユーザーの重要メモ')
    end
  end
end
