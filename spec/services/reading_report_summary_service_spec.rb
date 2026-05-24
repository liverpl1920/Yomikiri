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
      reference_date = Date.new(2026, 5, 31)

      create(:reading_log, book: book_a, read_at: Date.new(2026, 5, 1), pages_read: 10)
      create(:reading_log, book: book_b, read_at: Date.new(2026, 5, 20), pages_read: 40)
      create(:reading_log, book: book_b, read_at: Date.new(2026, 4, 30), pages_read: 100) # 範囲外

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
             start_page: 10, end_page: 40)
      create(:reading_log, book: book_b, read_at: Date.new(2026, 5, 15), pages_read: 20,
             start_page: nil, end_page: nil)

      summary = described_class.call(user: user, period_type: :weekly,
                                     reference_date: Date.new(2026, 5, 17))

      details = summary[:reading_log_details]
      expect(details.size).to eq(2)
      expect(details.first[:book_title]).to eq('リファクタリング')
      expect(details.first[:start_page]).to eq(10)
      expect(details.first[:end_page]).to eq(40)
      expect(details.first[:pages_read]).to eq(30)
      expect(details.last[:start_page]).to be_nil
    end

    it '未対応の period_type では例外を返す' do
      expect {
        described_class.call(user: user, period_type: :daily)
      }.to raise_error(ArgumentError, 'Unsupported period type: daily')
    end
  end
end
