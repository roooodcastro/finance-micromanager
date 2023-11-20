class RenameAccountUsersToAccountShares < ActiveRecord::Migration[7.0]
  def change
    rename_table :account_users, :account_shares
  end
end
