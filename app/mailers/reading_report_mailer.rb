class ReadingReportMailer < ApplicationMailer
  def weekly_report(user, reference_date = Date.current)
    build_mail(user:, period_type: :weekly, reference_date:)
  end

  def monthly_report(user, reference_date = Date.current)
    build_mail(user:, period_type: :monthly, reference_date:)
  end

  def yearly_report(user, reference_date = Date.current)
    build_mail(user:, period_type: :yearly, reference_date:)
  end

  private

  def build_mail(user:, period_type:, reference_date:)
    @user = user
    @summary = ReadingReportSummaryService.call(
      user: user,
      period_type: period_type,
      reference_date: reference_date
    )

    subject_label = case period_type.to_sym
    when :weekly then "週次"
    when :monthly then "月次"
    when :yearly then "年次"
    end

    period_text = if period_type.to_sym == :yearly
                    "#{@summary[:start_date].year}年"
    else
                    "#{@summary[:start_date]}〜#{@summary[:end_date]}"
    end

    mail(to: @user.email, subject: "【Yomikiri】#{subject_label}読書レポート（#{period_text}）")
  end
end
