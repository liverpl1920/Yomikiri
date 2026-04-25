# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'トップ画面遷移', type: :system do
  it '未ログイン時はトップ画面を表示する' do
    visit root_path

    expect(page).to have_text('積読を消化する技術')
    expect(page).to have_link('無料で始める')
    expect(page).to have_link('ログイン')
  end

  it 'ログイン済みでトップへアクセスすると積読一覧へ遷移する' do
    user = create(:user)
    login_as(user, scope: :user)

    visit root_path

    expect(page).to have_current_path(books_path)
  end

  describe 'ログアウト後遷移', js: true do
    it 'ログアウトするとトップ画面へ遷移しゲストヘッダーになる' do
      user = create(:user)
      Warden.test_reset!
      sign_in_via_form(user)

      visit books_path
      wait_for_stimulus

      page.execute_script(%q{document.querySelector('[data-action="dropdown#toggle"]').click()})
      click_button 'ログアウト'

      expect(page).to have_current_path(root_path)
      expect(page).to have_link('無料で始める')
      expect(page).to have_link('ログイン')
    end
  end
end
