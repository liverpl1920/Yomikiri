# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dashboards', type: :request do
  let(:user) { create(:user, nickname: 'テスト読書家') }

  describe 'GET /dashboard' do
    context '未ログインの場合' do
      it 'ログイン画面へリダイレクトされる' do
        get dashboard_path

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'ログイン済みの場合' do
      before { sign_in user }

      it '200 OK を返す' do
        get dashboard_path

        expect(response).to have_http_status(:ok)
      end

      it 'ユーザーのウェルカムメッセージが表示される' do
        get dashboard_path

        expect(response.body).to include('おかえりなさい、テスト読書家 さん')
      end

      describe '読書データの計算検証' do
        let!(:reading_book) { create(:book, user: user, status: :reading, pages: 300, current_page: 50, deadline: 5.days.from_now.to_date) }
        let!(:completed_book) { create(:book, user: user, status: :completed, pages: 200, current_page: 200, completed_at: Date.current) }

        it '進行中の本と最近読了した本が正しく表示される' do
          get dashboard_path

          expect(response.body).to include(reading_book.title)
          expect(response.body).to include(completed_book.title)
        end

        context '読書ストリーク（連続読書日数）の計算' do
          it '読書記録がない場合はストリークが0であること' do
            get dashboard_path

            expect(response.body).to include('<span class="dashboard__stat-number">0</span>')
          end

          it '今日と昨日読書した記録がある場合はストリークが2であること' do
            create(:reading_log, book: reading_book, pages_read: 10, read_at: Date.current)
            create(:reading_log, book: reading_book, pages_read: 20, read_at: Date.current - 1.day)

            get dashboard_path

            expect(response.body).to include('<span class="dashboard__stat-number">2</span>')
          end

          it '今日読書し昨日が空いて一昨日に読書した記録がある場合はストリークが1であること' do
            create(:reading_log, book: reading_book, pages_read: 10, read_at: Date.current)
            create(:reading_log, book: reading_book, pages_read: 20, read_at: Date.current - 2.days)

            get dashboard_path

            expect(response.body).to include('<span class="dashboard__stat-number">1</span>')
          end
        end

        context '週次アクティビティ（過去7日間の日別ページ数）の集計' do
          it '過去7日間の読書ログが曜日キーに正しく対応してページ数が表示されること' do
            create(:reading_log, book: reading_book, pages_read: 15, read_at: Date.current)
            create(:reading_log, book: reading_book, pages_read: 25, read_at: Date.current - 2.days)

            get dashboard_path

            # 今日の分の棒グラフタイトル（日付: ページ数）が含まれていることを検証
            today_str = I18n.l(Date.current, format: :short)
            expect(response.body).to include("#{today_str}: 15ページ")

            two_days_ago_str = I18n.l(Date.current - 2.days, format: :short)
            expect(response.body).to include("#{two_days_ago_str}: 25ページ")
          end
        end
      end
    end
  end

  describe 'GET /dashboard/lookback' do
    context '未ログインの場合' do
      it 'ログイン画面へリダイレクトされる' do
        get lookback_dashboard_path

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'ログイン済みの場合' do
      before { sign_in user }

      context '読了済みの本が存在しない場合' do
        it '200 OK を返し、ランダム振り返りカードが表示されないこと' do
          get lookback_dashboard_path

          expect(response).to have_http_status(:ok)
          expect(response.body).not_to include('lookback-card')
        end
      end

      context '読了済みの本が存在する場合' do
        let!(:completed_book) { create(:book, user: user, status: :completed, title: '読了本タイトル', rating: 4, review: 'とても面白かった。') }

        it '200 OK を返し、ランダム振り返りカードに書籍タイトルや感想・評価が表示されること' do
          get lookback_dashboard_path

          expect(response).to have_http_status(:ok)
          expect(response.body).to include('lookback-card')
          expect(response.body).to include('読了本タイトル')
          expect(response.body).to include('★★★★☆')
          expect(response.body).to include('とても面白かった。')
        end

        context 'メモも存在する場合' do
          let!(:book_memo) { create(:book_memo, book: completed_book, content: '感銘を受けたメモ', page_number: '123') }

          it 'メモの内容やページ番号が表示されること' do
            get lookback_dashboard_path

            expect(response.body).to include('感銘を受けたメモ')
            expect(response.body).to include('p. 123')
          end
        end
      end
    end
  end
end
