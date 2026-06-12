require 'rails_helper'

RSpec.describe ReadingReportSummaryService do
  describe '.call' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:book_a) { create(:book, user: user, title: 'リファクタリング') }
    let(:book_b) { create(:book, user: user, title: '達人プログラマー') }
    let(:other_book) { create(:book, user: other_user, title: '他ユーザー本') }

    it '週次期間の読書実績をユーザー単位で集計する' do
      reference_date = Date.new(2026, 5, 17)

      create(:reading_log, book: book_a, read_at: Date.new(2026, 5, 17), pages_read: 30)
      create(:reading_log, book: book_a, read_at: Date.new(2026, 5, 12), pages_read: 20)
      create(:reading_log, book: book_b, read_at: Date.new(2026, 5, 10), pages_read: 99) # 範囲外
      create(:reading_log, book: other_book, read_at: Date.new(2026, 5, 16), pages_read: 50)

      summary = described_class.call(user: user, period_type: :weekly, reference_date: reference_date)

      expect(summary[:period_type]).to eq(:weekly)
      expect(summary[:period_label]).to eq('週次')
      expect(summary[:start_date]).to eq(Date.new(2026, 5, 11))
      expect(summary[:end_date]).to eq(Date.new(2026, 5, 17))
      expect(summary[:total_pages]).to eq(50)
      expect(summary[:books]).to eq([
        { title: 'リファクタリング', pages_read: 50 }
      ])
    end

    it '月次期間の読書実績を集計する' do
      reference_date = Date.new(2026, 6, 1) # 翌月1日を指定

      create(:reading_log, book: book_a, read_at: Date.new(2026, 5, 1), pages_read: 10)
      create(:reading_log, book: book_b, read_at: Date.new(2026, 5, 20), pages_read: 40)
      create(:reading_log, book: book_b, read_at: Date.new(2026, 6, 1), pages_read: 100) # 範囲外（翌月）

      summary = described_class.call(user: user, period_type: :monthly, reference_date: reference_date)

      expect(summary[:period_type]).to eq(:monthly)
      expect(summary[:period_label]).to eq('月次')
      expect(summary[:start_date]).to eq(Date.new(2026, 5, 1))
      expect(summary[:end_date]).to eq(Date.new(2026, 5, 31))
      expect(summary[:total_pages]).to eq(50)
      expect(summary[:books]).to eq([
        { title: '達人プログラマー', pages_read: 40 },
        { title: 'リファクタリング', pages_read: 10 }
      ])
    end

    describe 'monthly details' do
      it '月次独自の指標を集計する' do
        reference_date = Date.new(2026, 6, 1)

        book_completed = nil
        book_new = nil
        book_progressing = nil

        travel_to(Date.new(2026, 5, 5)) do
          book_completed = create(:book, user: user, title: '読了本', pages: 100, current_page: 0, deadline: Date.new(2026, 5, 20), extension_count: 2)
          book_progressing = create(:book, user: user, title: '進行本', pages: 300, current_page: 0, deadline: Date.new(2026, 6, 10))
        end

        travel_to(Date.new(2026, 5, 10)) do
          book_new = create(:book, user: user, title: '新規本', pages: 200, deadline: Date.new(2026, 6, 15))
        end

        travel_to(Date.new(2026, 5, 15)) do
          book_completed.update!(current_page: 100, completed_at: Time.zone.now, status: :completed)
        end

        travel_to(Date.new(2026, 5, 16)) do
          book_progressing.update!(current_page: 50, status: :reading)
        end

        create(:reading_log, book: book_completed, read_at: Date.new(2026, 5, 15), pages_read: 100)
        create(:reading_log, book: book_progressing, read_at: Date.new(2026, 5, 16), pages_read: 50)

        travel_to(Date.new(2026, 5, 20)) do
          create(:book_memo, book: book_progressing, content: 'テストメモ')
        end

        summary = described_class.call(user: user, period_type: :monthly, reference_date: reference_date)

        expect(summary[:reading_days_count]).to eq(2)
        expect(summary[:completed_books]).to eq([ { title: '読了本', completed_at: Date.new(2026, 5, 15) } ])
        expect(summary[:progressing_books]).to eq([ { title: '進行本', pages_read: 50 } ])
        expect(summary[:tsundoku_balance]).to eq({ registered: 3, completed: 1 })
        expect(summary[:deadline_status][:completed_in_deadline]).to eq(1)
        expect(summary[:deadline_status][:extensions]).to eq(2)
        expect(summary[:deadline_status][:overdue_count]).to eq(0)

        expect(summary[:next_month_urgent_books].size).to eq(2)
        expect(summary[:next_month_urgent_books].first[:title]).to eq('進行本')
        expect(summary[:random_memos].size).to eq(1)
        expect(summary[:random_memos].first[:content]).to eq('テストメモ')
      end
    end

    describe 'yearly details' do
      it '年次期間の読書実績およびアワードを集計する' do
        reference_date = Date.new(2027, 1, 1)

        book_lightning = nil
        book_faced = nil
        book_ongoing = nil

        travel_to(Date.new(2026, 1, 1)) do
          book_faced = create(:book, user: user, title: '向き合い本', pages: 500, current_page: 0, deadline: Date.new(2027, 3, 1))
        end

        travel_to(Date.new(2026, 5, 10)) do
          book_lightning = create(:book, user: user, title: '電光石火本', pages: 100, current_page: 0, deadline: Date.new(2026, 5, 20), extension_count: 1)
        end

        travel_to(Date.new(2026, 5, 12)) do
          book_lightning.update!(current_page: 100, completed_at: Time.zone.now, status: :completed)
        end

        travel_to(Date.new(2026, 12, 1)) do
          book_ongoing = create(:book, user: user, title: '未了本', pages: 200, current_page: 50, status: :reading, deadline: Date.new(2027, 2, 1))
        end

        create(:reading_log, book: book_lightning, read_at: Date.new(2026, 5, 12), pages_read: 100)
        create(:reading_log, book: book_faced, read_at: Date.new(2026, 10, 5), pages_read: 200)
        create(:reading_log, book: book_faced, read_at: Date.new(2026, 11, 1), pages_read: 50)

        travel_to(Date.new(2026, 11, 1)) do
          book_faced.update!(current_page: 250, status: :reading)
        end

        travel_to(Date.new(2026, 10, 5)) do
          create(:book_memo, book: book_faced, content: '向き合いメモ1')
        end
        travel_to(Date.new(2026, 10, 6)) do
          create(:book_memo, book: book_faced, content: '向き合いメモ2')
        end

        summary = described_class.call(user: user, period_type: :yearly, reference_date: reference_date)

        expect(summary[:period_type]).to eq(:yearly)
        expect(summary[:period_label]).to eq('年次')
        expect(summary[:start_date]).to eq(Date.new(2026, 1, 1))
        expect(summary[:end_date]).to eq(Date.new(2026, 12, 31))
        expect(summary[:total_pages]).to eq(350)
        expect(summary[:yearly_completed_books_count]).to eq(1)
        expect(summary[:yearly_reading_days_count]).to eq(3)
        expect(summary[:peak_month]).to eq(10)

        expect(summary[:lightning_award_book]).to eq({ title: '電光石火本', days: 2 })
        expect(summary[:most_faced_book]).to eq({ title: '向き合い本', pages_read: 250 })
        expect(summary[:excuse_award_book]).to eq({ title: '電光石火本', extension_count: 1 })

        expect(summary[:most_memo_book_and_excerpt][:title]).to eq('向き合い本')
        expect(summary[:most_memo_book_and_excerpt][:total_memos]).to eq(2)
        expect(summary[:most_memo_book_and_excerpt][:excerpt_content]).to be_present

        expect(summary[:tsundoku_current_state][:count]).to eq(2)
        expect(summary[:tsundoku_current_state][:total_pages]).to eq(400)

        expect(summary[:new_year_proposal_book]).to eq('未了本')
      end
    end

    it 'カスタム期間の読書実績を集計する' do
      create(:reading_log, book: book_a, read_at: Date.new(2026, 5, 5), pages_read: 15)
      create(:reading_log, book: book_b, read_at: Date.new(2026, 5, 8), pages_read: 25)
      create(:reading_log, book: book_a, read_at: Date.new(2026, 5, 1), pages_read: 99) # 範囲外

      summary = described_class.call(
        user: user,
        period_type: :custom,
        start_date: Date.new(2026, 5, 3),
        end_date: Date.new(2026, 5, 10)
      )

      expect(summary[:period_type]).to eq(:custom)
      expect(summary[:period_label]).to eq('カスタム期間')
      expect(summary[:start_date]).to eq(Date.new(2026, 5, 3))
      expect(summary[:end_date]).to eq(Date.new(2026, 5, 10))
      expect(summary[:total_pages]).to eq(40)
    end

    it '日別ページ数を返す' do
      reference_date = Date.new(2026, 5, 13)

      create(:reading_log, book: book_a, read_at: Date.new(2026, 5, 11), pages_read: 10)
      create(:reading_log, book: book_b, read_at: Date.new(2026, 5, 11), pages_read: 5)
      create(:reading_log, book: book_a, read_at: Date.new(2026, 5, 13), pages_read: 20)

      summary = described_class.call(user: user, period_type: :weekly, reference_date: reference_date)

      expect(summary[:daily_pages][Date.new(2026, 5, 11)]).to eq(15)
      expect(summary[:daily_pages][Date.new(2026, 5, 13)]).to eq(20)
      expect(summary[:daily_pages][Date.new(2026, 5, 12)]).to eq(0)
      expect(summary[:daily_pages].keys).to eq((Date.new(2026, 5, 7)..Date.new(2026, 5, 13)).to_a)
    end

    it '読書ログ詳細を返す' do
      create(:reading_log, book: book_a, read_at: Date.new(2026, 5, 17), pages_read: 30,
             start_page: 11, end_page: 40)
      create(:reading_log, book: book_b, read_at: Date.new(2026, 5, 15), pages_read: 20,
             start_page: nil, end_page: nil)

      summary = described_class.call(user: user, period_type: :weekly,
                                     reference_date: Date.new(2026, 5, 17))

      details = summary[:reading_log_details]
      expect(details.size).to eq(2)
      expect(details.first[:book_title]).to eq('リファクタリング')
      expect(details.first[:start_page]).to eq(11)
      expect(details.first[:end_page]).to eq(40)
      expect(details.first[:pages_read]).to eq(30)
      expect(details.last[:start_page]).to be_nil
    end

    it '未対応の period_type では例外を返す' do
      expect {
        described_class.call(user: user, period_type: :daily)
      }.to raise_error(ArgumentError, 'Unsupported period type: daily')
    end

    describe 'memo_details' do
      it '週次期間内のメモをユーザー単位で返す' do
        reference_date = Date.new(2026, 5, 17) # 土曜

        # 期間内のメモ (2026-05-11〜05-17)
        memo_in  = create(:book_memo, book: book_a, content: '期間内メモ',
                          created_at: Time.zone.local(2026, 5, 15, 10, 0, 0))
        # 期間外のメモ (2026-05-10 23:59 は範囲外)
        _memo_out = create(:book_memo, book: book_a, content: '期間外メモ',
                           created_at: Time.zone.local(2026, 5, 10, 23, 59, 59))
        # 他ユーザーのメモは除外される
        _other_memo = create(:book_memo, book: other_book, content: '他ユーザーメモ',
                             created_at: Time.zone.local(2026, 5, 14, 10, 0, 0))

        summary = described_class.call(user: user, period_type: :weekly, reference_date: reference_date)

        memos = summary[:memo_details]
        expect(memos.size).to eq(1)
        expect(memos.first[:book_title]).to eq('リファクタリング')
        expect(memos.first[:content]).to eq('期間内メモ')
        expect(memos.first[:created_at]).to eq(Date.new(2026, 5, 15))
      end

      it 'page_number があるメモは page_number を返す' do
        reference_date = Date.new(2026, 5, 17)
        create(:book_memo, :with_page_number, book: book_a, content: 'ページ番号付きメモ',
               created_at: Time.zone.local(2026, 5, 12, 9, 0, 0))

        summary = described_class.call(user: user, period_type: :weekly, reference_date: reference_date)

        expect(summary[:memo_details].first[:page_number]).to eq('100-120')
      end

      it 'メモがない場合は空配列を返す' do
        summary = described_class.call(user: user, period_type: :weekly,
                                       reference_date: Date.new(2026, 5, 17))

        expect(summary[:memo_details]).to eq([])
      end
    end

    describe 'genres' do
      let(:book_backend) { create(:book, user: user, title: 'Go言語', genre: 'バックエンド') }
      let(:book_frontend) { create(:book, user: user, title: 'React実践', genre: 'フロントエンド') }
      let(:book_no_genre) { create(:book, user: user, title: '無の書', genre: nil) }
      let(:book_empty_genre) { create(:book, user: user, title: '空の書', genre: '') }

      it 'ジャンルごとの読了ページ数および比率を集計し、降順（同数の場合はジャンル名順）でソートする' do
        reference_date = Date.new(2026, 5, 17)

        create(:reading_log, book: book_backend, read_at: Date.new(2026, 5, 15), pages_read: 60)
        create(:reading_log, book: book_frontend, read_at: Date.new(2026, 5, 16), pages_read: 30)
        create(:reading_log, book: book_no_genre, read_at: Date.new(2026, 5, 17), pages_read: 10)
        create(:reading_log, book: book_empty_genre, read_at: Date.new(2026, 5, 14), pages_read: 20)

        summary = described_class.call(user: user, period_type: :weekly, reference_date: reference_date)

        expect(summary[:genres]).to eq([
          { name: 'バックエンド', pages_read: 60, ratio: 50.0 },
          { name: 'フロントエンド', pages_read: 30, ratio: 25.0 },
          { name: '未分類', pages_read: 30, ratio: 25.0 }
        ])
      end

      it '読書ログがない場合は空配列を返す' do
        summary = described_class.call(user: user, period_type: :weekly, reference_date: Date.new(2026, 5, 17))
        expect(summary[:genres]).to eq([])
      end
    end
  end
end
