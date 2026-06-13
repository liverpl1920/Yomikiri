# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '進捗更新', type: :system do
  let!(:user) { create(:user) }
  let!(:book) { create(:book, user: user, title: '進捗テスト本', pages: 200, current_page: 0) }

  describe '現在ページ入力フォーム（非JS）' do
    before { login_as(user, scope: :user) }

    it '現在ページを入力して進捗を更新できる' do
      visit book_path(book)

      fill_in 'direct_page', with: 30
      click_button '更新する'

      expect(page).to have_current_path(book_path(book))
      expect(page).to have_text('進捗を更新しました')
      expect(page).to have_text('30 / 200')
    end

    it 'ページ数が負の場合はエラーが表示される' do
      visit book_path(book)

      fill_in 'direct_page', with: -1
      click_button '更新する'

      expect(page).to have_text('ページ数が無効です')
    end

    it '今日読んだページ数フォームと折りたたみボタンが表示されない' do
      visit book_path(book)

      expect(page).to have_no_field('pages_read')
      expect(page).to have_no_text('今日読んだページ数')
      expect(page).to have_no_button('現在ページを直接入力')
      expect(page).to have_field('direct_page')
    end
  end

  describe '現在ページ入力フォーム（JS）', js: true do
    before do
      login_as(user, scope: :user)
      visit book_path(book)
    end

    context 'ダイアログでOKを選択した場合' do
      it '進捗が正常に更新される' do
        fill_in 'direct_page', with: 30

        accept_confirm("新しく 30 ページ読み進めましたか？（累計: 30 ページ）") do
          click_button '更新する'
        end

        expect(page).to have_current_path(book_path(book))
        expect(page).to have_text('進捗を更新しました')
        expect(page).to have_text('30 / 200')
      end
    end

    context 'ダイアログでキャンセルを選択した場合' do
      it '進捗の更新がキャンセルされ、入力値が維持される' do
        fill_in 'direct_page', with: 40

        dismiss_confirm("新しく 40 ページ読み進めましたか？（累計: 40 ページ）") do
          click_button '更新する'
        end

        expect(page).to have_current_path(book_path(book))
        expect(page).to have_no_text('進捗を更新しました')
        expect(find_field('direct_page').value).to eq '40'
        expect(book.reload.current_page).to eq 0
      end
    end

    context '差分が0の場合' do
      it '差分が0のメッセージが表示され、更新できる' do
        fill_in 'direct_page', with: 0

        accept_confirm("進捗を更新しますか？（累計: 0 ページ）") do
          click_button '更新する'
        end

        expect(page).to have_text('進捗を更新しました')
      end
    end

    context '差分が負の場合' do
      before do
        book.update!(current_page: 50)
        visit book_path(book)
      end

      it '差分が負のメッセージが表示され、更新（戻す）できる' do
        fill_in 'direct_page', with: 30

        accept_confirm("現在のページ数を戻しますか？（累計: 30 ページ）") do
          click_button '更新する'
        end

        expect(page).to have_text('進捗を更新しました')
        expect(page).to have_text('30 / 200')
      end
    end
  end
end
