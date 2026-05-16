class CreateReadingLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :reading_logs do |t|
      t.references :book, null: false, foreign_key: true
      t.integer :pages_read, null: false
      t.date :read_at, null: false

      t.timestamps
    end

    add_index :reading_logs, [:book_id, :read_at]
  end
end