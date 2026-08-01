class AddRetireReasonToBooks < ActiveRecord::Migration[7.2]
  def change
    add_column :books, :retire_reason, :text
  end
end
