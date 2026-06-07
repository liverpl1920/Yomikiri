# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'トップ画面遷移', type: :system do
  it '未ログイン時はトップ画面を表示する' do
    visit root_path

    expect(page).to have_text('積読を消化する技術')
    expect(page).to have_link('無料で始める')
    expect(page).to have_link('ログイン')
  end

  it 'ログイン済みでトップへアクセスするとダッシュボードへ遷移する' do
    user = create(:user)
    login_as(user, scope: :user)

    visit root_path

    expect(page).to have_current_path(dashboard_path)
  end

  describe 'ログアウト後遷移', js: true do
    before do
      Warden.test_reset!
    end

    it 'ログアウトするとトップ画面へ遷移しゲストヘッダーになる' do
      user = create(:user)
      sign_in_via_form(user)

      visit books_path
      wait_for_stimulus

      execute_script(%q{document.querySelector('[data-action="dropdown#toggle"]').click()})
      expect(page).to have_css('.dropdown__menu.dropdown__menu--open', wait: 3)
      execute_script(%q{document.querySelector('.dropdown__logout-form').requestSubmit()})

      expect(page).to have_current_path(root_path, wait: 5)
      expect(page).to have_link('無料で始める')
      expect(page).to have_link('ログイン')
    end
  end
end
