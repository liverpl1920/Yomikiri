# frozen_string_literal: true

class AddGenreToBooks < ActiveRecord::Migration[7.2]
  def change
    add_column :books, :genre, :string
  end
end
