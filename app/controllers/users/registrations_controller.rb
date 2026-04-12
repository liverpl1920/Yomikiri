# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    before_action :configure_sign_up_params, only: [ :create ]

    def update
      self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
      if resource.update_with_password(account_update_params)
        sign_out resource
        redirect_to new_user_session_path, notice: "パスワードを変更しました。再度ログインしてください。"
      else
        clean_up_passwords resource
        set_minimum_password_length
        render :edit, status: :unprocessable_entity
      end
    end

    private

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
