require 'rails_helper'

RSpec.describe ReadingReportMailer, type: :mailer do
  describe '#weekly_report' do
    it '週次集計を本文に含めて送信する' do
      user = create(:user, email: 'weekly@example.com', nickname: '週次ユーザー')
      book = create(:book, user: user, title: '週次本')
      reference_date = Date.new(2026, 5, 17)

      create(:reading_log, book: book, read_at: Date.new(2026, 5, 16), pages_read: 12)

      mail = described_class.weekly_report(user, reference_date)

      expect(mail.to).to eq([ 'weekly@example.com' ])
      expect(mail.subject).to include('週次読書レポート')
      expect(mail.body.encoded).to include('合計読了ページ数: 12 ページ')
      expect(mail.body.encoded).to include('- 週次本: 12 ページ')
    end
  end

  describe '#monthly_report' do
    it '対象期間に読書実績がない場合も送信する' do
      user = create(:user, email: 'monthly@example.com', nickname: '月次ユーザー')
      reference_date = Date.new(2026, 5, 31)

      mail = described_class.monthly_report(user, reference_date)

      expect(mail.to).to eq([ 'monthly@example.com' ])
      expect(mail.subject).to include('月次読書レポート')
      expect(mail.body.encoded).to include('合計読了ページ数: 0 ページ')
      expect(mail.body.encoded).to include('- 該当なし')
    end
  end
end
