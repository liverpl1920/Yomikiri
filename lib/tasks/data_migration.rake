# frozen_string_literal: true

namespace :data_migration do
  desc "既存の読了済み書籍で、読書ログが存在しないものに対して読書ログを補完する"
  task backfill_reading_logs: :environment do
    puts "Start backfilling reading logs for completed books without reading logs..."

    target_books = Book.completed.left_outer_joins(:reading_logs).where(reading_logs: { id: nil }).distinct
    total_count = target_books.count

    puts "Found #{total_count} book(s) to backfill."

    processed_count = 0
    error_count = 0

    target_books.find_each do |book|
      next if book.reading_logs.exists?

      begin
        read_date = (book.completed_at || book.created_at).to_date

        book.reading_logs.create!(
          pages_read: book.pages,
          read_at: read_date,
          start_page: 1,
          end_page: book.pages
        )
        puts "Successfully backfilled Book ID: #{book.id} (#{book.title}) with #{book.pages} pages on #{read_date}."
        processed_count += 1
      rescue StandardError => e
        puts "Failed to backfill Book ID: #{book.id} (#{book.title}). Error: #{e.message}"
        error_count += 1
      end
    end

    puts "Finished backfilling reading logs."
    puts "Processed: #{processed_count}, Errors: #{error_count}."
  end
end
