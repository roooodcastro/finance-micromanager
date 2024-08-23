class CreateImportTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :import_transactions, id: :uuid do |t|
      t.references :import, type: :uuid, foreign_key: true, index: true, null: false
      t.references :wallet, type: :uuid, foreign_key: true, null: false
      t.references :category, type: :uuid, foreign_key: true, null: true
      t.references :match_transaction, type: :uuid, foreign_key: { to_table: :transactions }, null: true

      t.string :original_import_name, limit: 100, null: false
      t.string :name, limit: 100, null: false
      t.string :action, limit: 10, null: false, default: 'import'
      t.date :transaction_date, null: false
      t.monetize :amount, null: false

      t.timestamps
    end
  end
end
