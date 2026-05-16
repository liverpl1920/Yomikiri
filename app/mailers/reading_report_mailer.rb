class ReadingReportMailer < ApplicationMailer
  def weekly_report(user, reference_date = Date.current)
    build_mail(user:, period_type: :weekly, reference_date:)
  end

  def monthly_report(user, reference_date = Date.current)
    build_mail(user:, period_type: :monthly, reference_date:)
  end

  private

  def build_mail(user:, period_type:, reference_date:)
    @user = user
    @summary = ReadingReportSummaryService.call(
      user: user,
      period_type: period_type,
      reference_date: reference_date
    )

    subject_label = period_type == :weekly ? "週次" : "月次"
    period_text = "#{@summary[:start_date]}〜#{@summary[:end_date]}"

    mail(to: @user.email, subject: "【Yomikiri】#{subject_label}読書レポート（#{period_text}）")
  end
end
