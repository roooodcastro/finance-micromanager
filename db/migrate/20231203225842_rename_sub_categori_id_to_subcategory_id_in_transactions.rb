class RenameSubCategoriIdToSubcategoryIdInTransactions < ActiveRecord::Migration[7.0]
  def change
    rename_column :transactions, :sub_category_id, :subcategory_id
  end
end
