class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  has_many :books, dependent: :destroy
  has_many :book_memos, through: :books

  validates :nickname, length: { maximum: 50 }, allow_blank: true
  validates :yearly_goal, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  def completed_books_count
    books.completed.count
  end

  def completed_pages_total
    books.completed.sum(:pages)
  end

  def consecutive_reading_days
    dates = books.pluck(:updated_at).map(&:to_date).uniq.sort.reverse
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
end
