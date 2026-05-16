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

  it '月末では monthly を実行する' do
    ENV['DATE'] = '2026-05-31'

    allow(ReadingReportDispatchJob).to receive(:perform_now)

    Rake::Task['reading_reports:dispatch'].invoke

    expect(ReadingReportDispatchJob).to have_received(:perform_now).with('monthly', Date.new(2026, 5, 31))
  end

  it '平日かつ月末以外ではスキップする' do
    ENV['DATE'] = '2026-05-13' # Wednesday

    allow(ReadingReportDispatchJob).to receive(:perform_now)

    Rake::Task['reading_reports:dispatch'].invoke

    expect(ReadingReportDispatchJob).not_to have_received(:perform_now)
  end
end
