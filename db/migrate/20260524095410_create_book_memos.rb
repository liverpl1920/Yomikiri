class CreateBookMemos < ActiveRecord::Migration[7.2]
  def change
    create_table :book_memos do |t|
      t.references :book, null: false, foreign_key: true
      t.text :content, null: false

      t.timestamps
    end
  end
end
