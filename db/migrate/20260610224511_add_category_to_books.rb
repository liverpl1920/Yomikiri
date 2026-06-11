class AddCategoryToBooks < ActiveRecord::Migration[7.2]
  def change
    add_column :books, :category, :integer, default: 0, null: false
  end
end
