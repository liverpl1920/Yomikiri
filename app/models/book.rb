class Book < ApplicationRecord
  belongs_to :user

  enum :status, { unread: 0, reading: 1, completed: 2 }

  validates :title, presence: true, length: { maximum: 255 }
  validates :total_pages, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :target_pages, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :current_page, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :deadline, presence: true
  validates :status, presence: true

  validate :target_pages_not_exceed_total_pages
  validate :current_page_not_exceed_target_pages

  # 積読一覧用ソートスコープ：未了本を期限順 → 読了本を期限順
  scope :for_index_list, lambda {
    completed_val = statuses[:completed]
    status_col = arel_table[:status]
    ordering = Arel::Nodes::Case.new.when(status_col.eq(completed_val)).then(1).else(0)
    order(ordering, :deadline)
  }

  # 今日のノルマ（残ページ ÷ 残日数、切り上げ）
  def daily_quota
    return 0 if completed?

    remaining = target_pages - current_page
    return 0 if remaining <= 0

    days = [ days_remaining, 1 ].max
    (remaining.to_f / days).ceil
  end

  # 進捗率（%）
  def progress_percentage
    return 100 if completed?
    return 0 if target_pages.zero?

    ((current_page.to_f / target_pages) * 100).round
  end

  # 残り日数（今日を含む）
  def days_remaining
    (deadline - Date.current).to_i
  end

  # 賞味期限ビジュアライザー用CSSクラス
  def deadline_urgency_class
    return "" if completed?

    days = days_remaining
    if days <= 1
      "book-card__cover--urgent-high"
    elsif days <= 3
      "book-card__cover--urgent-medium"
    elsif days <= 7
      "book-card__cover--urgent-low"
    else
      ""
    end
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
end
