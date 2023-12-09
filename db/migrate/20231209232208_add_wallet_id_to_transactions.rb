class AddWalletIdToTransactions < ActiveRecord::Migration[7.0]
  def change
    add_reference :transactions, :wallet, type: :uuid, index: true, foreign_key: true
  end
end
