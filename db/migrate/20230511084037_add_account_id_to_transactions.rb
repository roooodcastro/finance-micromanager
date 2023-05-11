class AddAccountIdToTransactions < ActiveRecord::Migration[7.0]
  def change
    add_reference :transactions, :account, null: false, index: true, foreign_key: true, type: :uuid
  end
end
