class BackfillReadingLogsForPastCompletedBooks < ActiveRecord::Migration[7.2]
  class Book < ActiveRecord::Base
    self.table_name = :books
    has_many :reading_logs, class_name: "BackfillReadingLogsForPastCompletedBooks::ReadingLog", foreign_key: :book_id
    enum :status, { unread: 0, reading: 1, completed: 2 }
  end

  class ReadingLog < ActiveRecord::Base
    self.table_name = :reading_logs
    belongs_to :book, class_name: "BackfillReadingLogsForPastCompletedBooks::Book", foreign_key: :book_id
  end

  def up
    target_books = Book.where(status: :completed)
                       .left_outer_joins(:reading_logs)
                       .where(reading_logs: { id: nil })
                       .distinct

    target_books.find_each do |book|
      next if book.reading_logs.exists?

      read_date = (book.completed_at || book.created_at).to_date

      book.reading_logs.create!(
        pages_read: book.pages,
        read_at: read_date,
        start_page: 1,
        end_page: book.pages
      )
    end
  end

  def down
    # 何もしない (移行処理の取り消しは行わない)
  end
end
