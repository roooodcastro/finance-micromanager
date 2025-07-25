class AddCreateAtStartOfPeriodToTransactionAutomations < ActiveRecord::Migration[8.0]
  def change
    add_column :transaction_automations, :create_at_start_of_period, :boolean, default: false, null: false
  end
end
