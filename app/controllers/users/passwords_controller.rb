# frozen_string_literal: true

module Users
  class PasswordsController < Devise::PasswordsController
    private

    def after_resetting_password_path_for(_resource)
      new_user_session_path
    end
  end
end
