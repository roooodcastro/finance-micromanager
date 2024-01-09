class AddTransactionAutomationIdToTransactions < ActiveRecord::Migration[7.0]
  def change
    add_reference :transactions, :transaction_automation, null: true, index: true, foreign_key: true, type: :uuid
  end
end
