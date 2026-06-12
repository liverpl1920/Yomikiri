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
      reference_date = Date.new(2026, 6, 1)

      mail = described_class.monthly_report(user, reference_date)

      expect(mail.to).to eq([ 'monthly@example.com' ])
      expect(mail.subject).to include('月次読書レポート')
      expect(mail.body.encoded).to include('総読書ページ数: 0 ページ')
      expect(mail.body.encoded).to include('- 該当なし')
    end

    it '実績がある場合は追加の指標を本文に含める' do
      user = create(:user, email: 'monthly_act@example.com', nickname: '月次アクティブ')
      book_completed = nil
      book_progressing = nil

      travel_to(Date.new(2026, 5, 5)) do
        book_completed = create(:book, user: user, title: '読了本', pages: 100, current_page: 0, deadline: Date.new(2026, 5, 20), extension_count: 1)
        book_progressing = create(:book, user: user, title: '進行本', pages: 200, current_page: 0, deadline: Date.new(2026, 6, 10))
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
        create(:book_memo, book: book_progressing, content: '大事なメモ')
      end

      mail = described_class.monthly_report(user, Date.new(2026, 6, 1))

      expect(mail.subject).to include('月次読書レポート')
      expect(mail.body.encoded).to include('総読書ページ数: 150 ページ')
      expect(mail.body.encoded).to include('- 読了本 (読了日: 2026-05-15)')
      expect(mail.body.encoded).to include('- 進行本: 50 ページ読了')
      expect(mail.body.encoded).to include('積読の増減: 新規登録 2 冊 vs 読了 1 冊')
      expect(mail.body.encoded).to include('期限内に読了できた本: 1 冊')
      expect(mail.body.encoded).to include('期限を延長した回数: 1 回')
      expect(mail.body.encoded).to include('今月残したブックメモの総数: 1 件')
      expect(mail.body.encoded).to include('大事なメモ')
    end
  end

  describe '#yearly_report' do
    it '年次読書実績や各種アワードを本文に含める' do
      user = create(:user, email: 'yearly@example.com', nickname: '年次ユーザー')
      book_lightning = nil
      book_faced = nil

      travel_to(Date.new(2026, 1, 1)) do
        book_faced = create(:book, user: user, title: '向き合い本', pages: 500, current_page: 0, deadline: Date.new(2027, 3, 1))
      end

      travel_to(Date.new(2026, 5, 10)) do
        book_lightning = create(:book, user: user, title: '電光石火本', pages: 100, current_page: 0, deadline: Date.new(2026, 5, 20), extension_count: 2)
      end

      travel_to(Date.new(2026, 5, 12)) do
        book_lightning.update!(current_page: 100, completed_at: Time.zone.now, status: :completed)
      end

      create(:reading_log, book: book_lightning, read_at: Date.new(2026, 5, 12), pages_read: 100)
      create(:reading_log, book: book_faced, read_at: Date.new(2026, 10, 5), pages_read: 200)

      travel_to(Date.new(2026, 10, 5)) do
        book_faced.update!(current_page: 200, status: :reading)
        create(:book_memo, book: book_faced, content: '長文の向き合いメモ')
      end

      mail = described_class.yearly_report(user, Date.new(2027, 1, 1))

      expect(mail.to).to eq([ 'yearly@example.com' ])
      expect(mail.subject).to include('年次読書レポート')
      expect(mail.subject).to include('2026年')
      expect(mail.body.encoded).to include('総読了冊数: 1 冊')
      expect(mail.body.encoded).to include('総読書ページ数: 300 ページ')
      expect(mail.body.encoded).to include('読書のピーク月: あなたが今年最も読書に没頭したのは 10月 でした！')
      expect(mail.body.encoded).to include('【電光石火アワード】')
      expect(mail.body.encoded).to include('- 『電光石火本』 (登録から 2 日で読了)')
      expect(mail.body.encoded).to include('【最も向き合った本】')
      expect(mail.body.encoded).to include('- 『向き合い本』 (今年 200 ページ読了)')
      expect(mail.body.encoded).to include('【言い訳アワード】')
      expect(mail.body.encoded).to include('- 『電光石火本』 (期限延長回数: 2 回)')
      expect(mail.body.encoded).to include('今年残したメモの総数: 1 件')
      expect(mail.body.encoded).to include('長文の向き合いメモ')
      expect(mail.body.encoded).to include('新年最初の読書目標に、まずはこちらの本から読み始めてみませんか？')
      expect(mail.body.encoded).to include('向き合い本')
    end
  end
end
