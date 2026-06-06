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
      expect(mail.body.encoded).to include('今週記録したメモ:')
    end

    it 'メモがある場合はメモ内容を本文に含める' do
      user = create(:user, email: 'weekly2@example.com', nickname: '週次ユーザー2')
      book = create(:book, user: user, title: 'メモ付き本')
      reference_date = Date.new(2026, 5, 17)

      create(:book_memo, book: book, content: '重要なポイント', page_number: '42',
             created_at: Time.zone.local(2026, 5, 14, 10, 0, 0))

      mail = described_class.weekly_report(user, reference_date)

      expect(mail.body.encoded).to include('メモ付き本')
      expect(mail.body.encoded).to include('（p.42）')
      expect(mail.body.encoded).to include('重要なポイント')
    end

    it 'メモがない場合は該当なしを本文に含める' do
      user = create(:user, email: 'weekly3@example.com', nickname: '週次ユーザー3')
      reference_date = Date.new(2026, 5, 17)

      mail = described_class.weekly_report(user, reference_date)

      expect(mail.body.encoded).to include('今週記録したメモ:')
      # メモがない場合と本がない場合のどちらにも「該当なし」が表示される
      expect(mail.body.encoded.scan('- 該当なし').size).to be >= 1
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
