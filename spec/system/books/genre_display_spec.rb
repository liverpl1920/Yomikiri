# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '一覧画面のジャンル表示', type: :system do
  let!(:user) { create(:user) }

  before { login_as(user, scope: :user) }

  describe '書籍一覧のジャンル表示' do
    it 'ジャンルが設定されている書籍は一覧にジャンルが表示される' do
      create(:book, user: user, title: 'ジャンルあり本', genre: 'プログラミング')

      visit books_path

      expect(page).to have_css('.book-card__genre', text: 'プログラミング')
    end

    it 'ジャンルが未設定の書籍は一覧にジャンルが表示されない' do
      create(:book, user: user, title: 'ジャンルなし本', genre: nil)

      visit books_path

      expect(page).not_to have_css('.book-card__genre')
    end

    it '複数の書籍がそれぞれのジャンルを表示する' do
      create(:book, user: user, title: '本A', genre: '技術書')
      create(:book, user: user, title: '本B', genre: 'ビジネス')
      create(:book, user: user, title: '本C', genre: nil)

      visit books_path

      expect(page).to have_css('.book-card__genre', text: '技術書')
      expect(page).to have_css('.book-card__genre', text: 'ビジネス')
      expect(page).to have_css('.book-card__genre', count: 2)
    end
  end
end
