# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '読了フロー', type: :system do
  let!(:user) { create(:user) }

  before { login_as(user, scope: :user) }

  describe '読了にする！ボタン' do
    context '未完了の書籍の場合' do
      let!(:book) { create(:book, user: user, title: '読了テスト本', pages: 100, current_page: 0) }

      it '「読了にする！」ボタンが表示される' do
        visit book_path(book)

        expect(page).to have_button('読了にする！')
      end

      it '「読了にする！」ボタンを押すとお祝いモーダルが表示される' do
        visit book_path(book)

        click_button '読了にする！'

        expect(page).to have_text('読了おめでとうございます！')
        expect(page).to have_text(book.title)
      end

      it 'お祝いモーダルに「一覧に戻る」リンクがある' do
        visit book_path(book)

        click_button '読了にする！'

        within('.celebration-modal-overlay') do
          expect(page).to have_link('一覧に戻る', href: books_path)
        end
      end

      it '「一覧に戻る」リンクで書籍一覧画面へ遷移する' do
        visit book_path(book)

        click_button '読了にする！'
        within('.celebration-modal-overlay') do
          click_link '一覧に戻る'
        end

        expect(page).to have_current_path(books_path)
      end
    end

    context '既に読了済みの書籍の場合' do
      let!(:completed_book) do
        create(:book, user: user, title: '読了済み本',
                      pages: 100, current_page: 100,
                      completed_at: 1.day.ago, status: :completed)
      end

      it '「読了にする！」ボタンが表示されない' do
        visit book_path(completed_book)

        expect(page).not_to have_button('読了にする！')
      end
    end
  end
end
