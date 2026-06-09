class AddNormalizedTitleToBooks < ActiveRecord::Migration[7.2]
  class MigrationBook < ActiveRecord::Base
    self.table_name = :books
  end

  def change
    add_column :books, :normalized_title, :string
    add_index :books, [:user_id, :normalized_title]

    reversible do |dir|
      dir.up do
        MigrationBook.reset_column_information
        MigrationBook.find_each do |book|
          normalized = book.title.to_s.unicode_normalize(:nfkc).gsub(/\s+/, '').downcase
          book.update_columns(normalized_title: normalized)
        end
      end
    end
  end
end
