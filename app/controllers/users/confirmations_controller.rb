# frozen_string_literal: true

module Users
  class ConfirmationsController < Devise::ConfirmationsController
    private

    def after_confirmation_path_for(resource_name, resource)
      sign_out(resource)
      email_change_complete_path
    end
  end
end
