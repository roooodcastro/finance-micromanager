class AddBalanceAmountToProfiles < ActiveRecord::Migration[7.0]
  def change
    add_monetize :profiles, :balance_amount, currency: { present: false }
  end
end
