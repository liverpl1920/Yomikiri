# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mypage stats', type: :request do
  let(:user) { create(:user) }

  describe 'GET /mypage/stats' do
    context '未ログインの場合' do
      it 'ログイン画面へリダイレクトされる' do
        get stats_mypage_path

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'ログイン済みの場合' do
      before { sign_in user }

      around do |example|
        travel_to(Date.new(2026, 5, 17)) { example.run }
      end

      it '週次集計を表示する' do
        book_a = create(:book, user: user, title: '週次本A')
        book_b = create(:book, user: user, title: '週次本B')

        create(:reading_log, book: book_a, read_at: Date.new(2026, 5, 17), pages_read: 20)
        create(:reading_log, book: book_b, read_at: Date.new(2026, 5, 12), pages_read: 10)
        create(:reading_log, book: book_b, read_at: Date.new(2026, 5, 10), pages_read: 99)

        create(:book, user: user, title: '読了済み（週次内）', status: :completed, completed_at: Time.zone.parse('2026-05-13 09:00:00'))
        create(:book, user: user, title: '読了済み（週次外）', status: :completed, completed_at: Time.zone.parse('2026-05-01 09:00:00'))

        get stats_mypage_path(period: 'weekly')

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('週次集計')
        expect(response.body).to include('週次本A')
        expect(response.body).to include('週次本B')
        expect(response.body).to include('30')
        expect(response.body).to include('読了冊数')
      end

      it '月次集計を表示する' do
        book = create(:book, user: user, title: '月次本')

        create(:reading_log, book: book, read_at: Date.new(2026, 5, 1), pages_read: 12)
        create(:reading_log, book: book, read_at: Date.new(2026, 5, 20), pages_read: 8)
        create(:reading_log, book: book, read_at: Date.new(2026, 4, 30), pages_read: 40)

        create(:book, user: user, title: '読了済み（月次内）', status: :completed, completed_at: Time.zone.parse('2026-05-03 09:00:00'))

        get stats_mypage_path(period: 'monthly')

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('月次集計')
        expect(response.body).to include('月次本')
        expect(response.body).to include('20')
      end

      it 'データなしの場合はゼロと空表示を返す' do
        get stats_mypage_path(period: 'weekly')

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('この期間の読書記録はありません。')
        expect(response.body).to include('0')
      end

      it '不正なperiod指定では週次にフォールバックする' do
        get stats_mypage_path(period: 'invalid')

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('週次集計')
      end
    end
  end
end
