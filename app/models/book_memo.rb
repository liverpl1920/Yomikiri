class BookMemo < ApplicationRecord
  CONTENT_MAX_LENGTH = 2000

  belongs_to :book

  validates :content, presence: true, length: { maximum: CONTENT_MAX_LENGTH }

  scope :latest_first, -> { order(created_at: :desc) }
end
