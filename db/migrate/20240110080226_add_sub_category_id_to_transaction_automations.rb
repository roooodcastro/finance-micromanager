class AddSubCategoryIdToTransactionAutomations < ActiveRecord::Migration[7.0]
  def change
    add_reference :transaction_automations, :transaction_subcategory, type: :uuid, index: true, foreign_key: { to_table: :subcategories }, null: true
  end
end
