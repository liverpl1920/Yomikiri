class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  has_many :books, dependent: :destroy
  has_many :book_memos, through: :books
  has_many :reading_logs, through: :books
  has_many :genres, dependent: :destroy

  DEFAULT_GENRES = [ "ビジネス", "小説・文学", "技術書・専門書", "自己啓発", "エッセイ・読み物", "実用書・趣味", "その他" ].freeze

  after_create :prepare_default_genres

  validates :nickname, length: { maximum: 50 }, allow_blank: true
  validates :yearly_goal, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  def completed_books_count
    books.completed.count
  end

  def completed_pages_total
    books.completed.sum(:pages)
  end

  def consecutive_reading_days
    dates = reading_logs.pluck(:read_at).uniq.sort.reverse
    return 0 if dates.empty?

    streak = 0
    check_date = dates.include?(Date.current) ? Date.current : Date.current - 1.day
    dates.each do |date|
      if date == check_date
        streak += 1
        check_date -= 1.day
      end
    end
    streak
  end

  def display_name
    nickname.presence || email
  end

  private

  def prepare_default_genres
    DEFAULT_GENRES.each do |name|
      genres.create!(name: name)
    end
  end
end
