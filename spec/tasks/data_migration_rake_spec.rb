# frozen_string_literal: true

require 'rails_helper'
require 'rake'

RSpec.describe 'data_migration:backfill_reading_logs' do
  before(:all) do
    Rake.application = Rake::Application.new
    Rails.application.load_tasks
  end

  before do
    Rake::Task['data_migration:backfill_reading_logs'].reenable
  end

  after(:all) do
    Rake.application = nil
  end

  let!(:user) { create(:user) }

  # 1. 読了済みで読書ログがない書籍
  let!(:completed_book_no_log) do
    create(:book, user: user, status: :completed, pages: 300, completed_at: 1.day.ago)
  end

  # 2. 読了済みですでに読書ログがある書籍
  let!(:completed_book_with_log) do
    book = create(:book, user: user, status: :completed, pages: 200, completed_at: 2.days.ago)
    create(:reading_log, book: book, pages_read: 200, read_at: 2.days.ago.to_date, start_page: 1, end_page: 200)
    book
  end

  # 3. 未読の書籍
  let!(:unread_book) do
    create(:book, user: user, status: :unread, pages: 150)
  end

  # 4. 読書中の書籍
  let!(:reading_book) do
    create(:book, user: user, status: :reading, pages: 250, current_page: 50)
  end

  it '読了済みで読書ログがない書籍に対してのみ、読書ログが補完されること' do
    expect {
      Rake::Task['data_migration:backfill_reading_logs'].invoke
    }.to change(ReadingLog, :count).by(1)

    # 補完された読書ログの検証
    log = completed_book_no_log.reading_logs.first
    expect(log).to be_present
    expect(log.pages_read).to eq(300)
    expect(log.read_at).to eq(completed_book_no_log.completed_at.to_date)
    expect(log.start_page).to eq(1)
    expect(log.end_page).to eq(300)

    # 他の書籍に読書ログが追加されていないこと
    expect(completed_book_with_log.reading_logs.count).to eq(1)
    expect(unread_book.reading_logs.count).to eq(0)
    expect(reading_book.reading_logs.count).to eq(0)
  end

  context 'completed_at が nil の場合' do
    let!(:completed_book_nil_completed_at) do
      # completed_at が nil の読了済み書籍
      create(:book, user: user, status: :completed, pages: 100, completed_at: nil, created_at: 3.days.ago)
    end

    it 'created_at の日付が read_at に設定されること' do
      Rake::Task['data_migration:backfill_reading_logs'].invoke

      log = completed_book_nil_completed_at.reading_logs.first
      expect(log).to be_present
      expect(log.read_at).to eq(completed_book_nil_completed_at.created_at.to_date)
    end
  end
end
