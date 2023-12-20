class AddIndexToReconciliationsDate < ActiveRecord::Migration[7.0]
  def change
    add_index :reconciliations, :date
  end
end
