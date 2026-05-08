# frozen_string_literal: true

module Users
  class PasswordsController < Devise::PasswordsController
    MAIL_DELIVERY_ERRORS = [
      Net::SMTPAuthenticationError,
      Net::SMTPServerBusy,
      Net::SMTPSyntaxError,
      Net::SMTPFatalError,
      Net::SMTPUnknownError,
      Timeout::Error,
      SocketError,
      EOFError,
      Errno::ECONNREFUSED,
      Errno::ECONNRESET,
      Errno::ETIMEDOUT
    ].freeze

    def create
      super
    rescue *MAIL_DELIVERY_ERRORS => e
      Rails.logger.error("[Users::PasswordsController] reset password mail delivery failed: #{e.class} #{e.message}")
      flash[:alert] = "現在メールを送信できません。時間をおいて再度お試しください。"
      redirect_to new_user_password_path
    end

    private

    def after_resetting_password_path_for(resource)
      sign_out(resource) if resource.present?
      new_user_session_path
    end
  end
end
