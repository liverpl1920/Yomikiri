class ApplicationMailer < ActionMailer::Base
  default from: -> { ENV.fetch("MAILER_SENDER", "noreply@yomikiri-app.com") }
  layout "mailer"
end
