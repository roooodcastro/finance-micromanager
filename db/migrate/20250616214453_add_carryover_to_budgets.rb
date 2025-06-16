class AddCarryoverToBudgets < ActiveRecord::Migration[7.1]
  def change
    add_column :budgets, :carryover, :boolean, null: false, default: false
  end
end
