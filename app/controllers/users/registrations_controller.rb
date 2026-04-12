# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    before_action :configure_sign_up_params, only: [ :create ]

    protected

    def build_resource(hash = {})
      super
      resource.skip_confirmation!
    end

    def after_sign_up_path_for(resource)
      books_path
    end

    private

    def configure_sign_up_params
      devise_parameter_sanitizer.permit(:sign_up, keys: [ :nickname ])
    end
  end
end
