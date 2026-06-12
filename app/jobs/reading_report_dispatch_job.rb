class ReadingReportDispatchJob < ApplicationJob
  queue_as :default

  PERIOD_TYPES = %w[weekly monthly yearly].freeze
  MAX_DELIVERY_ATTEMPTS = 3

  def perform(period_type, reference_date = Date.current)
    period_type = normalize_period_type(period_type)
    reference_date = reference_date.to_date

    validate_period_type!(period_type)

    User.find_each do |user|
      deliver_with_retry(user, period_type, reference_date)
    end
  end

  private

  def normalize_period_type(period_type)
    period_type.to_s
  end

  def validate_period_type!(period_type)
    return if PERIOD_TYPES.include?(period_type)

    raise ArgumentError, "Unsupported period type: #{period_type}"
  end

  def deliver_with_retry(user, period_type, reference_date)
    attempts = 0

    begin
      attempts += 1
      mail_for(user, period_type, reference_date).deliver_now
    rescue StandardError => e
      if attempts < MAX_DELIVERY_ATTEMPTS
        Rails.logger.warn("[ReadingReportDispatchJob] retry=#{attempts} user_id=#{user.id} period_type=#{period_type} error=#{e.class}: #{e.message}")
        retry
      end

      Rails.logger.error("[ReadingReportDispatchJob] delivery_failed user_id=#{user.id} period_type=#{period_type} attempts=#{attempts} error=#{e.class}: #{e.message}")
    end
  end

  def mail_for(user, period_type, reference_date)
    case period_type
    when "weekly"
      ReadingReportMailer.weekly_report(user, reference_date)
    when "monthly"
      ReadingReportMailer.monthly_report(user, reference_date)
    when "yearly"
      ReadingReportMailer.yearly_report(user, reference_date)
    end
  end
end
