class FixBudgetInstanceFkType < ActiveRecord::Migration[7.1]
  def change
    remove_reference :budget_instances, :budget
    add_reference :budget_instances, :budget, null: false, index: true, foreign_key: true, type: :uuid
  end
end
