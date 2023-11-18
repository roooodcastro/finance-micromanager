class CreateAccountShareInvites < ActiveRecord::Migration[7.0]
  def change
    create_table :account_share_invites, id: :uuid do |t|
      t.references :account, type: :uuid, null: false, foreign_key: true
      t.references :account_owner, type: :uuid, null: false, foreign_key: { to_table: :users }
      t.string :invitee_email, null: false, index: true
      t.string :status, null: false, limit: 15, default: 'pending'

      t.timestamps
    end

    add_index :account_share_invites, %i[account_id invitee_email], unique: true
  end
end
