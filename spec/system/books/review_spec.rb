require 'rails_helper'

RSpec.describe '読了後の評価・感想', type: :system do
  let!(:user) { create(:user) }
  let!(:book) { create(:book, user: user, title: '読了レビューテスト本', target_pages: 100, current_page: 0) }

  before do
    login_as(user, scope: :user)
    visit book_path(book)
  end

  describe '読了お祝いモーダルでの入力' do
    before do
      click_button '読了にする！'
    end

    it '評価と感想を入力して保存できる' do
      within('.celebration-modal') do
        find('label[for="star5"]').click
        fill_in '感想', with: '最高の一冊でした。'
        click_button '評価・感想を保存して一覧に戻る'
      end

      expect(page).to have_current_path(books_path)
      expect(page).to have_content('評価・感想を保存しました。')

      # 詳細画面で表示されているか確認
      visit book_path(book)
      expect(page).to have_content('あなたの評価・感想')
      expect(page).to have_content('★★★★★')
      expect(page).to have_content('最高の一冊でした。')
    end

    it '何も入力せずに保存せずに戻ることもできる' do
      within('.celebration-modal') do
        click_link '保存せずに一覧に戻る'
      end

      expect(page).to have_current_path(books_path)

      # 詳細画面で評価セクションが表示されていないことを確認
      visit book_path(book)
      expect(page).not_to have_content('あなたの評価・感想')
    end
  end

  describe '詳細画面での表示' do
    context '既に評価・感想がある場合' do
      let!(:completed_book) do
        create(:book, user: user, status: :completed, rating: 4, review: '読みやすかった', current_page: 300, target_pages: 300)
      end

      it '詳細画面に評価と感想が表示される' do
        visit book_path(completed_book)
        expect(page).to have_content('あなたの評価・感想')
        expect(page).to have_content('★★★★☆')
        expect(page).to have_content('読みやすかった')
      end
    end
  end
end
