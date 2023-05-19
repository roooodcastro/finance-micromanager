class IncreateCategoryColorColumnSize < ActiveRecord::Migration[7.0]
  def change
    change_column :categories, :color, :string, limit: 7
  end
end
