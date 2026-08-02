class AddReadCountToBooks < ActiveRecord::Migration[7.2]
  def change
    add_column :books, :read_count, :integer, default: 0, null: false

    reversible do |dir|
      dir.up do
        Book.reset_column_information

        # 同一ユーザー・同一タイトルの書籍をグループ化して古い順に read_count を設定する
        Book.where.not(normalized_title: [nil, ""]).select(:user_id, :normalized_title).unscope(:order).distinct.each do |group|
          books = Book.where(user_id: group.user_id, normalized_title: group.normalized_title).order(:id)
          completed_counter = 0
          books.each do |book|
            if book.completed?
              completed_counter += 1
              book.update_columns(read_count: completed_counter)
            else
              book.update_columns(read_count: 0)
            end
          end
        end

        # セーフガード：なんらかの理由で completed なのに read_count が 0 のままの本を 1 に設定する
        Book.where(status: :completed, read_count: 0).update_all(read_count: 1)
      end
    end
  end
end
