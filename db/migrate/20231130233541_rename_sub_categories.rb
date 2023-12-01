class RenameSubCategories < ActiveRecord::Migration[7.0]
  def change
    rename_table :sub_categories, :subcategories
  end
end
