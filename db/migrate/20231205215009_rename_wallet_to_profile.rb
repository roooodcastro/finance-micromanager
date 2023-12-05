class RenameWalletToProfile < ActiveRecord::Migration[7.0]
  def change
    rename_table :wallets, :profiles
  end
end
