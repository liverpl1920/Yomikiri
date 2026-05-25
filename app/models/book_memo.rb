class BookMemo < ApplicationRecord
  CONTENT_MAX_LENGTH = 2000
  PAGE_NUMBER_MAX_LENGTH = 20

  belongs_to :book

  validates :content, presence: true, length: { maximum: CONTENT_MAX_LENGTH }
  validates :page_number, length: { maximum: PAGE_NUMBER_MAX_LENGTH }, allow_blank: true

  scope :latest_first, -> { order(created_at: :desc) }

  def edited?
    (updated_at - created_at) > 1.second
  end
end
