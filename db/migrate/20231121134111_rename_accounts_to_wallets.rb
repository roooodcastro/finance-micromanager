class RenameAccountsToWallets < ActiveRecord::Migration[7.0]
  def change
    rename_table :accounts, :wallets
    rename_table :account_shares, :wallet_shares
    rename_table :account_share_invites, :wallet_share_invites
  end
end
