class SetCurrencyAsNotNullInAccounts < ActiveRecord::Migration[7.0]
  def change
    change_column :accounts, :currency, :string, null: false, default: nil
  end
end
