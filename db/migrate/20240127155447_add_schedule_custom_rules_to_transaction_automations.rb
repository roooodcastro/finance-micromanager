class AddScheduleCustomRulesToTransactionAutomations < ActiveRecord::Migration[7.1]
  def change
    add_column :transaction_automations, :schedule_custom_rule, :string, limit: 50
  end
end
