# frozen_string_literal: true

module Users
  class EmailChangesController < ApplicationController
    before_action :authenticate_user!, except: [ :complete ]

    def edit; end

    def update
      current_password = params[:current_password]
      new_email = params[:email]

      unless current_user.valid_password?(current_password)
        current_user.errors.add(:current_password, "が違います")
        render :edit, status: :unprocessable_entity
        return
      end

      current_user.email = new_email
      if current_user.save
        redirect_to mypage_path, notice: t("email_change.confirmation_sent")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def complete; end
  end
end
