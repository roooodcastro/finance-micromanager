class AddSubCategoryIdToTransactions < ActiveRecord::Migration[7.0]
  def change
    add_reference :transactions, :sub_category, type: :uuid, index: true, foreign_key: true, null: true
  end
end
