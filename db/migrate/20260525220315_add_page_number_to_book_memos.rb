class AddPageNumberToBookMemos < ActiveRecord::Migration[7.2]
  def change
    add_column :book_memos, :page_number, :string
  end
end
