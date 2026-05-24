class ReadingLog < ApplicationRecord
  belongs_to :book

  validates :pages_read, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :read_at, presence: true
  validates :start_page, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :end_page, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
end
