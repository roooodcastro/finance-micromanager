class AddUserIdToAccounts < ActiveRecord::Migration[7.0]
  def change
    add_reference :accounts, :user, index: true, foreign_key: true, type: :uuid
  end
end
