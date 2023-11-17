class CreateAccountUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :account_users, id: :uuid do |t|
      t.references :account, type: :uuid, null: false, index: true, foreign_key: true
      t.references :user, type: :uuid, null: false, index: true, foreign_key: true

      t.timestamps
    end
  end
end
