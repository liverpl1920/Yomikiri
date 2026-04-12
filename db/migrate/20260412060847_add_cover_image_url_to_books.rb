class AddCoverImageUrlToBooks < ActiveRecord::Migration[7.2]
  def change
    add_column :books, :cover_image_url, :string
  end
end
