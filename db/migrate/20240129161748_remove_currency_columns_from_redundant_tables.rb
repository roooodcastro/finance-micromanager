class RemoveCurrencyColumnsFromRedundantTables < ActiveRecord::Migration[7.1]
  def change
    remove_column :transactions, :amount_currency, :string, default: 'EUR'
    remove_column :wallets, :balance_currency, :string, default: 'EUR'
  end
end
