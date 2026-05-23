class AddRatingAndReviewToBooks < ActiveRecord::Migration[7.2]
  def change
    add_column :books, :rating, :integer
    add_column :books, :review, :text
  end
end
