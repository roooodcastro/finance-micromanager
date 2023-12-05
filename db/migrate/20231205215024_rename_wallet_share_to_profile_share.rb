class RenameWalletShareToProfileShare < ActiveRecord::Migration[7.0]
  def change
    rename_table :wallet_shares, :profile_shares
  end
end
