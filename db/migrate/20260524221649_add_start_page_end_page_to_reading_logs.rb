class AddStartPageEndPageToReadingLogs < ActiveRecord::Migration[7.2]
  def change
    add_column :reading_logs, :start_page, :integer
    add_column :reading_logs, :end_page, :integer
  end
end
