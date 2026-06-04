class ModifyBooksForEnhancements < ActiveRecord::Migration[7.2]
  def up
    # 1. total_pages を pages に変更
    rename_column :books, :total_pages, :pages

    # 2. もし target_pages の値が total_pages と異なる場合、pages を target_pages で更新する
    # (進捗の分母が target_pages だったので、進捗の整合性を保つため)
    execute <<-SQL
      UPDATE books SET pages = target_pages WHERE target_pages IS NOT NULL AND target_pages != pages;
    SQL

    # 3. target_pages を削除
    remove_column :books, :target_pages

    # 4. translator (string) と publisher (string) を追加
    add_column :books, :translator, :string
    add_column :books, :publisher, :string
  end

  def down
    remove_column :books, :publisher
    remove_column :books, :translator

    add_column :books, :target_pages, :integer
    execute <<-SQL
      UPDATE books SET target_pages = pages;
    SQL
    rename_column :books, :pages, :total_pages
  end
end
