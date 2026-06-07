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
        expect(page).to have_text("0 / 50")
      end

      it 'ユーザーの年間目標がダッシュボードの表示に反映されること' do
        user.update!(yearly_goal: 12)
        visit dashboard_path

        expect(page).to have_text("0 / 12")
      end

      it '過去（前年以前）に読了した本が年間目標の進捗に含まれず、今年読了した本のみが含まれること' do
        # 前年に読了した本
        create(:book, user: user, status: :completed, title: '前年の本', completed_at: Time.current.prev_year)
        # 今年に読了した本
        create(:book, user: user, status: :completed, title: '今年の本', completed_at: Time.current)

        visit dashboard_path

        # 年間目標（今年読了した本のみが分子）
        expect(page).to have_text("1 / 50")
        # 読書統計の累計（全期間の合計）
        expect(page).to have_text("2")
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

      it '過去の振り返り（ランダム振り返り）セクションが表示され、シャッフル動作が機能すること' do
        completed_book1 = create(:book, user: user, status: :completed, title: '過去の読了本A', rating: 4, review: 'Aの感想', completed_at: Date.current)
        create(:book_memo, book: completed_book1, content: 'Aのメモ', page_number: '10')

        completed_book2 = create(:book, user: user, status: :completed, title: '過去の読了本B', rating: 5, review: 'Bの感想', completed_at: Date.current)
        create(:book_memo, book: completed_book2, content: 'Bのメモ', page_number: '20')

        visit dashboard_path

        expect(page).to have_text(I18n.t('dashboards.lookback.lookback_title'))
        expect(page).to have_css('.lookback-card')
        expect(page).to have_link('別の本')

        # シャッフルリンクのクリック
        click_link '別の本'
        expect(page).to have_css('.lookback-card')
      end

      context '過去の振り返り（ランダム振り返り）での書影画像表示' do
        it '書影画像がある場合、画像が表示されること' do
          completed_book = create(:book, user: user, status: :completed, title: '画像あり本', rating: 4, completed_at: Date.current)
          completed_book.cover_image.attach(
            io: StringIO.new('fake png data'),
            filename: 'cover.png',
            content_type: 'image/png'
          )

          visit dashboard_path

          expect(page).to have_css('.lookback-card__cover-image')
          expect(page).not_to have_css('.lookback-card__cover-placeholder')
        end

        it '書影画像がない場合、プレースホルダーが表示されること' do
          create(:book, user: user, status: :completed, title: '画像なし本', rating: 5, completed_at: Date.current)

          visit dashboard_path

          expect(page).to have_css('.lookback-card__cover-placeholder')
          expect(page).not_to have_css('.lookback-card__cover-image')
        end
      end
    end
  end
end
