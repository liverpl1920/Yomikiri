namespace :reading_reports do
  desc "週末・月末条件に応じて読書レポート配信ジョブを実行する"
  task dispatch: :environment do
    reference_date = parse_reference_date
    run_weekly = reference_date.saturday? || reference_date.sunday?
    run_monthly = reference_date == reference_date.end_of_month

    ReadingReportDispatchJob.perform_now("weekly", reference_date) if run_weekly
    ReadingReportDispatchJob.perform_now("monthly", reference_date) if run_monthly

    unless run_weekly || run_monthly
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

  def parse_reference_date
    Date.parse(ENV.fetch("DATE", Date.current.to_s))
  rescue ArgumentError
    raise ArgumentError, "Invalid DATE format: #{ENV['DATE']}"
  end
end
