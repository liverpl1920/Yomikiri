class CreateBooks < ActiveRecord::Migration[7.2]
  def change
    create_table :books do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.string :author
      t.integer :total_pages, null: false
      t.integer :target_pages, null: false
      t.integer :current_page, null: false, default: 0
      t.date :deadline, null: false
      t.integer :status, null: false, default: 0
      t.integer :extension_count, null: false, default: 0
      t.datetime :completed_at

      t.timestamps
    end
  end
end
