class CreateAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :accounts, id: :uuid do |t|
      t.string :status, null: false, limit: 15, default: 'active'

      t.timestamps
    end
  end
end
