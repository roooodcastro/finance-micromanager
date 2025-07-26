class AddScheduleDayToTransactionAutomations < ActiveRecord::Migration[8.0]
  def change
    add_column :transaction_automations, :schedule_day, :integer, null: true
  end
end
