class ChangeDeadlineNullableInBooks < ActiveRecord::Migration[7.2]
  def change
    change_column_null :books, :deadline, true
  end
end
