class Book < ApplicationRecord
  belongs_to :user

  enum :status, { unread: 0, reading: 1, completed: 2 }

  validates :title, presence: true, length: { maximum: 255 }
  validates :author, length: { maximum: 255 }, allow_blank: true
  validates :total_pages, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :target_pages, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :current_page, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :deadline, presence: true
  validates :status, presence: true

  validate :target_pages_not_exceed_total_pages
  validate :current_page_not_exceed_target_pages
  validate :deadline_cannot_be_in_the_past, on: :create

  def remaining_pages
    target_pages - current_page
  end

  def remaining_days
    return 0 if deadline.nil? || deadline < Date.current

    (deadline - Date.current).to_i + 1
  end

  def calculate_daily_quota
    return 0 if remaining_pages <= 0 || remaining_days <= 0

    (remaining_pages.to_f / remaining_days).ceil
  end

  def progress_percentage
    return 0 if target_pages.zero?

    ((current_page.to_f / target_pages) * 100).round(1)
  end

  private

  def target_pages_not_exceed_total_pages
    return if target_pages.blank? || total_pages.blank?

    errors.add(:target_pages, :less_than_or_equal_to, count: total_pages) if target_pages > total_pages
  end

  def current_page_not_exceed_target_pages
    return if current_page.blank? || target_pages.blank?

    errors.add(:current_page, :less_than_or_equal_to, count: target_pages) if current_page > target_pages
  end

  def deadline_cannot_be_in_the_past
    return if deadline.blank?

    errors.add(:deadline, :past_date) if deadline < Date.current
  end
end
