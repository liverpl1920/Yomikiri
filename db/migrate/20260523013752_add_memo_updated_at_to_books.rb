class AddMemoUpdatedAtToBooks < ActiveRecord::Migration[7.2]
  def change
    add_column :books, :memo_updated_at, :datetime
  end
end
