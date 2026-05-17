class Book < ApplicationRecord
  MEMO_MAX_LENGTH = 2000

  belongs_to :user
  has_many :reading_logs, dependent: :destroy

  attr_accessor :is_past_reading, :completed_at_input

  enum :status, { unread: 0, reading: 1, completed: 2 }

  validates :title, presence: true, length: { maximum: 255 }
  validates :author, length: { maximum: 255 }, allow_blank: true
  validates :memo, length: { maximum: MEMO_MAX_LENGTH }, allow_blank: true
  validates :cover_image_url, length: { maximum: 2048 }, allow_blank: true
  validates :total_pages, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :target_pages, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :current_page, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :deadline, presence: true
  validates :status, presence: true

  validate :target_pages_not_exceed_total_pages
  validate :current_page_not_exceed_target_pages
  validate :current_page_not_exceed_total_pages
  validate :deadline_cannot_be_in_the_past, if: -> { new_record? || will_save_change_to_deadline? }
  validate :cover_image_url_must_be_valid_url, if: -> { cover_image_url.present? }
  validate :completed_at_must_be_valid_date, if: -> { past_reading_checked? && completed_at_input.present? }
  validate :completed_at_must_not_be_in_future, if: -> { past_reading_checked? && completed_at_input.present? }

  before_save :auto_set_reading_status
  before_save :apply_past_reading_settings

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

  scope :title_like, ->(query) { where("title ILIKE ?", "%#{sanitize_sql_like(query)}%") }
  scope :author_like, ->(query) { where("author ILIKE ?", "%#{sanitize_sql_like(query)}%") }
  scope :genre_like, ->(query) { where("genre ILIKE ?", "%#{sanitize_sql_like(query)}%") }
  scope :completed_from, ->(from_date) { where("completed_at >= ?", from_date.beginning_of_day) }
  scope :completed_to, ->(to_date) { where("completed_at <= ?", to_date.end_of_day) }

  def self.filtered_for_index(params)
    relation = for_index_list
    relation = relation.title_like(params[:title]) if params[:title].present?
    relation = relation.author_like(params[:author]) if params[:author].present?
    relation = relation.genre_like(params[:genre]) if params[:genre].present?
    relation = relation.completed_from(params[:completed_from]) if params[:completed_from].present?
    relation = relation.completed_to(params[:completed_to]) if params[:completed_to].present?
    relation
  end

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

  def completed_at_must_be_valid_date
    return if completed_at_input.blank?

    begin
      Date.parse(completed_at_input)
    rescue Date::Error, TypeError
      errors.add(:completed_at_input, :invalid)
    end
  end

  def completed_at_must_not_be_in_future
    return if completed_at_input.blank?

    begin
      date = Date.parse(completed_at_input)
      errors.add(:completed_at_input, :future_date) if date > Date.current
    rescue Date::Error, TypeError
      # This error is handled by completed_at_must_be_valid_date
    end
  end

  def apply_past_reading_settings
    return unless past_reading_checked?

    self.status = :completed
    self.current_page = target_pages

    if completed_at_input.present?
      self.completed_at = Time.zone.parse(completed_at_input.to_s)
    else
      self.completed_at = Time.current
    end
  end

  def past_reading_checked?
    ActiveModel::Type::Boolean.new.cast(is_past_reading)
  end

  def target_pages_not_exceed_total_pages
    return if target_pages.blank? || total_pages.blank?

    errors.add(:target_pages, :less_than_or_equal_to, count: total_pages) if target_pages > total_pages
  end

  def current_page_not_exceed_target_pages
    return if current_page.blank? || target_pages.blank?
    return if total_pages.present? && current_page > total_pages

    errors.add(:current_page, :less_than_or_equal_to, count: target_pages) if current_page > target_pages
  end

  def current_page_not_exceed_total_pages
    return if current_page.blank? || total_pages.blank?

    errors.add(:current_page, :less_than_or_equal_to_total_pages, count: total_pages) if current_page > total_pages
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
