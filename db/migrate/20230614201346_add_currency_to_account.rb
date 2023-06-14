class AddCurrencyToAccount < ActiveRecord::Migration[7.0]
  def change
    add_column :accounts, :currency, :string, limit: 3, null: false, default: 'USD'
  end
end
