# frozen_string_literal: true

class GenresController < ApplicationController
  before_action :authenticate_user!
  before_action :set_genre, only: %i[edit update destroy]

  def edit; end

  def create
    @genre = current_user.genres.build(genre_params)

    if @genre.save
      respond_to do |format|
        format.turbo_stream { render :create }
        format.html { redirect_to mypage_path, notice: "ジャンルを追加しました。" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :create_error, status: :unprocessable_entity }
        format.html { redirect_to mypage_path, alert: @genre.errors.full_messages.join(", ") }
      end
    end
  end

  def update
    if @genre.update(genre_params)
      respond_to do |format|
        format.turbo_stream { render :update }
        format.html { redirect_to mypage_path, notice: "ジャンルを更新しました。" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :update_error, status: :unprocessable_entity }
        format.html { redirect_to mypage_path, alert: @genre.errors.full_messages.join(", ") }
      end
    end
  end

  def destroy
    @genre_id = @genre.id
    @genre.destroy!
    respond_to do |format|
      format.turbo_stream { render :destroy }
      format.html { redirect_to mypage_path, notice: "ジャンルを削除しました。", status: :see_other }
    end
  end

  private

  def set_genre
    @genre = current_user.genres.find_by(id: params[:id])
    render file: Rails.public_path.join("404.html"), status: :not_found, layout: false unless @genre
  end

  def genre_params
    params.require(:genre).permit(:name)
  end
end
