class AddMemoUpdatedAtToBooks < ActiveRecord::Migration[7.2]
  def change
    add_column :books, :memo_updated_at, :datetime

    # 既存レコードのうちメモが入っているものは updated_at でバックフィルする
    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE books
          SET memo_updated_at = updated_at
          WHERE memo IS NOT NULL AND memo != ''
        SQL
      end
    end
  end
end
