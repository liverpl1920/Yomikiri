# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    private

    def after_sign_up_path_for(resource)
      books_path
    end
  end
end
