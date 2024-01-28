class RenameNextScheduleDate < ActiveRecord::Migration[7.1]
  def change
    rename_column :transaction_automations, :next_schedule_date, :scheduled_date
  end
end
