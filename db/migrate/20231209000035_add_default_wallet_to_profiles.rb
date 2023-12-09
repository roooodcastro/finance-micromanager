class AddDefaultWalletToProfiles < ActiveRecord::Migration[7.0]
  def change
    add_reference :profiles, :default_wallet, type: :uuid, index: true, foreign_key: { to_table: :wallets }
  end
end
