class AddMemoToBooks < ActiveRecord::Migration[7.2]
  def change
    add_column :books, :memo, :text
  end
end
