require 'rails_helper'

RSpec.describe ReadingReportDispatchJob, type: :job do
  describe '#perform' do
    let(:reference_date) { Date.new(2026, 5, 17) }

    it '週次レポートを全ユーザーに送信する' do
      user1 = create(:user, email: 'u1@example.com')
      user2 = create(:user, email: 'u2@example.com')

      create(:reading_log, book: create(:book, user: user1, title: '本A'), pages_read: 10, read_at: reference_date)
      create(:reading_log, book: create(:book, user: user2, title: '本B'), pages_read: 20, read_at: reference_date)

      expect {
        described_class.perform_now('weekly', reference_date)
      }.to change { ActionMailer::Base.deliveries.count }.by(2)
    end

    it '年次レポートを全ユーザーに送信する' do
      user1 = create(:user, email: 'u1@example.com')
      ref_date = Date.new(2027, 1, 1)

      expect {
        described_class.perform_now('yearly', ref_date)
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it '未対応の period_type では例外を発生させる' do
      expect {
        described_class.perform_now('daily', reference_date)
      }.to raise_error(ArgumentError, 'Unsupported period type: daily')
    end

    it '送信失敗時は再試行して最終失敗をログ出力する' do
      user = create(:user)
      mail = instance_double(ActionMailer::MessageDelivery)
      attempts = 0

      allow(ReadingReportMailer).to receive(:weekly_report).with(user, reference_date).and_return(mail)
      allow(mail).to receive(:deliver_now) do
        attempts += 1
        raise Net::SMTPFatalError, 'smtp error'
      end
      allow(Rails.logger).to receive(:warn)
      allow(Rails.logger).to receive(:error)

      described_class.perform_now('weekly', reference_date)

      expect(attempts).to eq(3)
      expect(Rails.logger).to have_received(:warn).twice
      expect(Rails.logger).to have_received(:error).once
    end
  end
end
