require 'rails_helper'
require 'rake'

RSpec.describe 'reading_reports:dispatch' do
  before(:all) do
    Rake.application = Rake::Application.new
    Rails.application.load_tasks
  end

  before do
    Rake::Task['reading_reports:dispatch'].reenable
  end

  after do
    ENV.delete('DATE')
  end

  after(:all) do
    Rake.application = nil
  end

  it '週末では weekly を実行する' do
    ENV['DATE'] = '2026-05-17' # Sunday

    allow(ReadingReportDispatchJob).to receive(:perform_now)

    Rake::Task['reading_reports:dispatch'].invoke

    expect(ReadingReportDispatchJob).to have_received(:perform_now).with('weekly', Date.new(2026, 5, 17))
    expect(ReadingReportDispatchJob).not_to have_received(:perform_now).with('monthly', Date.new(2026, 5, 17))
  end

  it '毎月1日では monthly を実行する' do
    ENV['DATE'] = '2026-06-01'

    allow(ReadingReportDispatchJob).to receive(:perform_now)

    Rake::Task['reading_reports:dispatch'].invoke

    expect(ReadingReportDispatchJob).to have_received(:perform_now).with('monthly', Date.new(2026, 6, 1))
    expect(ReadingReportDispatchJob).not_to have_received(:perform_now).with('yearly', Date.new(2026, 6, 1))
  end

  it '毎年1月1日では monthly と yearly を実行する' do
    ENV['DATE'] = '2027-01-01'

    allow(ReadingReportDispatchJob).to receive(:perform_now)

    Rake::Task['reading_reports:dispatch'].invoke

    expect(ReadingReportDispatchJob).to have_received(:perform_now).with('monthly', Date.new(2027, 1, 1))
    expect(ReadingReportDispatchJob).to have_received(:perform_now).with('yearly', Date.new(2027, 1, 1))
  end

  it '平日かつ1日以外ではスキップする' do
    ENV['DATE'] = '2026-05-13' # Wednesday (and not 1st)

    allow(ReadingReportDispatchJob).to receive(:perform_now)

    Rake::Task['reading_reports:dispatch'].invoke

    expect(ReadingReportDispatchJob).not_to have_received(:perform_now)
  end
end
