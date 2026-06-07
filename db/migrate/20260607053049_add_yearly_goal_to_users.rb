class AddYearlyGoalToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :yearly_goal, :integer, default: 50, null: false
  end
end
