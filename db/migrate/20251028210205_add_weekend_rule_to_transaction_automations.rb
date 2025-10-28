class AddWeekendRuleToTransactionAutomations < ActiveRecord::Migration[8.0]
  def change
    add_column :transaction_automations, :weekend_rule, :string
  end
end
