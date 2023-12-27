class AddCategoryTypeToCategories < ActiveRecord::Migration[7.0]
  def change
    add_column :categories, :category_type, :string, limit: 20, null: false, default: 'user'
  end
end
