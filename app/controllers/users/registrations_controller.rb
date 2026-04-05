# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    before_action :configure_sign_up_params, only: [ :create ]

    private

    def configure_sign_up_params
      devise_parameter_sanitizer.permit(:sign_up, keys: [ :nickname ])
    end

    def after_sign_up_path_for(resource)
      books_path
    end
  end
end
