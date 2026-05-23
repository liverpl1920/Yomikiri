class AddIsbnToBooks < ActiveRecord::Migration[7.2]
  def change
    add_column :books, :isbn, :string
  end
end
