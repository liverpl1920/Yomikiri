class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :books, dependent: :destroy

  validates :nickname, length: { maximum: 50 }, allow_blank: true

  def completed_books_count
    books.completed.count
  end

  def completed_pages_total
    books.completed.sum(:target_pages)
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
