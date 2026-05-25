class ReadingLog < ApplicationRecord
  belongs_to :book

  validates :pages_read, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :read_at, presence: true
  validates :start_page, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :end_page, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validate :start_end_page_consistency

  private

  def start_end_page_consistency
    both_nil = start_page.nil? && end_page.nil?
    return if both_nil

    if start_page.nil? || end_page.nil?
      errors.add(:base, "開始ページと終了ページは両方指定してください")
    elsif end_page <= start_page
      errors.add(:end_page, "は開始ページより大きい必要があります")
    end
  end
end
