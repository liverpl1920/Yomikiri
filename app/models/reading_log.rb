class ReadingLog < ApplicationRecord
  belongs_to :book

  validates :pages_read, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :read_at, presence: true
end
