namespace :reading_reports do
  desc "週末・月末・年末条件に応じて読書レポート配信ジョブを実行する"
  task dispatch: :environment do
    reference_date = parse_reference_date
    run_weekly = reference_date.saturday? || reference_date.sunday?
    run_monthly = reference_date.day == 1
    run_yearly = reference_date.month == 1 && reference_date.day == 1

    ReadingReportDispatchJob.perform_now("weekly", reference_date) if run_weekly
    ReadingReportDispatchJob.perform_now("monthly", reference_date) if run_monthly
    ReadingReportDispatchJob.perform_now("yearly", reference_date) if run_yearly

    unless run_weekly || run_monthly || run_yearly
      Rails.logger.info("[reading_reports:dispatch] skipped date=#{reference_date}")
    end
  end

  desc "週次読書レポートを配信する"
  task weekly: :environment do
    reference_date = parse_reference_date
    ReadingReportDispatchJob.perform_now("weekly", reference_date)
  end

  desc "月次読書レポートを配信する"
  task monthly: :environment do
    reference_date = parse_reference_date
    ReadingReportDispatchJob.perform_now("monthly", reference_date)
  end

  desc "年次読書レポートを配信する"
  task yearly: :environment do
    reference_date = parse_reference_date
    ReadingReportDispatchJob.perform_now("yearly", reference_date)
  end

  def parse_reference_date
    date_str = ENV["DATE"].presence
    if date_str
      Date.parse(date_str)
    else
      Date.current
    end
  rescue ArgumentError, Date::Error
    raise ArgumentError, "Invalid DATE format: #{ENV['DATE']}"
  end
end
