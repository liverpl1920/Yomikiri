# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ダッシュボード', type: :system do
  let!(:user) { create(:user, nickname: 'テスト読書家') }

  describe '表示' do
    it '未ログイン時はログイン画面へ遷移する' do
      visit dashboard_path

      expect(page).to have_current_path(new_user_session_path)
    end

    context 'ログイン済みの場合' do
      before do
        login_as(user, scope: :user)
      end

      it 'ダッシュボード画面の各セクションが表示されること' do
        visit dashboard_path

        expect(page).to have_text(I18n.t('dashboards.show.welcome_back', user: 'テスト読書家'))
        expect(page).to have_text(I18n.t('dashboards.show.current_reads'))
        expect(page).to have_text(I18n.t('dashboards.show.stats'))
        expect(page).to have_text(I18n.t('dashboards.show.reading_goal'))
        expect(page).to have_text(I18n.t('dashboards.show.weekly_activity'))
        expect(page).to have_text(I18n.t('dashboards.show.recently_finished'))
      end

      it '進行中の本がない場合に空メッセージと登録リンクが表示されること' do
        visit dashboard_path

        expect(page).to have_text(I18n.t('dashboards.show.no_reading_books'))
        expect(page).to have_link(I18n.t('dashboards.show.add_book'), href: new_book_path)
      end

      it '進行中の本がある場合に書籍タイトル、進捗、今日のノルマが表示されること' do
        reading_book = create(:book, user: user, status: :reading, title: '進行中テスト本', pages: 300, current_page: 100, deadline: Date.current + 5.days)

        visit dashboard_path

        expect(page).to have_link('進行中テスト本', href: book_path(reading_book))
        expect(page).to have_text("100 / 300")
        # ノルマは残200ページ / 6日(今日含む) = 34ページ
        expect(page).to have_text("34")
      end

      it '最近読了した本がある場合にその書籍と評価が表示されること' do
        completed_book = create(:book, user: user, status: :completed, title: '読了テスト本', pages: 200, current_page: 200, rating: 5, completed_at: Date.current)

        visit dashboard_path

        expect(page).to have_text('読了テスト本')
        expect(page).to have_text('★★★★★')
      end
    end
  end
end
