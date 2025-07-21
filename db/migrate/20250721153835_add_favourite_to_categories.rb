class AddFavouriteToCategories < ActiveRecord::Migration[7.1]
  def change
    add_column :categories, :favourite, :boolean, default: false, null: false
  end
end
