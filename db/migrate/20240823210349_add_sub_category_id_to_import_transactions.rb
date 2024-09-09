class AddSubCategoryIdToImportTransactions < ActiveRecord::Migration[7.1]
  def change
    add_reference :import_transactions, :subcategory, type: :uuid, index: true, foreign_key: true, null: true
  end
end
