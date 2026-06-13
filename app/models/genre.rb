# frozen_string_literal: true

class Genre < ApplicationRecord
  MAX_PER_USER = 50

  belongs_to :user

  validates :name, presence: true, uniqueness: { scope: :user_id }
  validate :user_genres_count_within_limit, on: :create

  private

  def user_genres_count_within_limit
    return unless user

    if user.genres.count >= MAX_PER_USER
      errors.add(:base, :too_many_genres, max: MAX_PER_USER)
    end
  end
end
