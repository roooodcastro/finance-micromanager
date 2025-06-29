class AddUniqueIndexToBudgets < ActiveRecord::Migration[7.1]
  def change
    add_index :budgets, :owner_id, unique: true
  end
end
