class AllowNilInTransactionAutomationScheduleInterval < ActiveRecord::Migration[7.1]
  def change
    change_column :transaction_automations, :schedule_interval, :integer, null: true
  end
end
