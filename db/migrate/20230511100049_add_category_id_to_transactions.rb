class AddCategoryIdToTransactions < ActiveRecord::Migration[7.0]
  def change
    add_reference :transactions, :category, type: :uuid, null: false, index: true, foreign_key: true
  end
end
