class Book < ApplicationRecord
  belongs_to :user

  enum :status, { unread: 0, reading: 1, completed: 2 }

  validates :title, presence: true, length: { maximum: 255 }
  validates :author, length: { maximum: 255 }, allow_blank: true
  validates :cover_image_url, length: { maximum: 2048 }, allow_blank: true
  validates :total_pages, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :target_pages, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :current_page, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :deadline, presence: true
  validates :status, presence: true

  validate :target_pages_not_exceed_total_pages
  validate :current_page_not_exceed_target_pages
  validate :deadline_cannot_be_in_the_past, if: -> { new_record? || will_save_change_to_deadline? }
  validate :cover_image_url_must_be_valid_url, if: -> { cover_image_url.present? }

  before_save :auto_set_reading_status

  def extend_deadline!(new_deadline)
    return false if new_deadline.blank?
    return errors.add(:deadline, :must_be_after_current_deadline) && false if new_deadline <= deadline

    self.deadline = new_deadline
    self.extension_count += 1
    save
  end

  def remaining_pages
    target_pages - current_page
  end

  # 積読一覧用ソートスコープ：未了本を期限順 → 読了本を期限順
  scope :for_index_list, lambda {
    completed_val = statuses[:completed]
    status_col = arel_table[:status]
    ordering = Arel::Nodes::Case.new.when(status_col.eq(completed_val)).then(1).else(0)
    order(ordering, :deadline)
  }

  # 今日のノルマ（残ページ ÷ 残日数、切り上げ）
  # 期限超過時（D <= 0）は D=1 として計算する
  def daily_quota
    return 0 if completed?

    remaining = target_pages - current_page
    return 0 if remaining <= 0

    days = overdue? ? 1 : days_remaining
    (remaining.to_f / days).ceil
  end

  # 進捗率（%）
  def progress_percentage
    return 100 if completed?
    return 0 if target_pages.zero?

    ((current_page.to_f / target_pages) * 100).round
  end

  # 残り日数（今日を含む／期限当日は D=1）
  def days_remaining
    (deadline - Date.current).to_i + 1
  end

  # 期限超過判定（D <= 0、すなわち期限日翌日以降）
  def overdue?
    days_remaining <= 0
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

  def deadline_cannot_be_in_the_past
    return if deadline.blank?

    errors.add(:deadline, :past_date) if deadline < Date.current
  end

  def cover_image_url_must_be_valid_url
    uri = URI.parse(cover_image_url)
    errors.add(:cover_image_url, :invalid_url) unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
  rescue URI::InvalidURIError
    errors.add(:cover_image_url, :invalid_url)
  end

  # 初回の進捗記録（current_page が 0 → 1 以上）時に unread → reading へ自動遷移する
  def auto_set_reading_status
    return unless unread?
    return unless persisted?
    return unless current_page_changed?
    return unless current_page_was.to_i.zero?
    return if current_page.to_i.zero?

    self.status = :reading
  end
end
