class AddTransactionImportIdToTransactions < ActiveRecord::Migration[7.1]
  def change
    add_column :transactions, :import_preview_id, :uuid, null: true

    add_index :transactions, :import_preview_id
  end
end
