class CreateWallets < ActiveRecord::Migration[7.0]
  def change
    create_table :wallets, id: :uuid do |t|
      t.references :profile, type: :uuid,foreign_key: true, index: true, null: false
      t.string :name, limit: 50, null: false
      t.monetize :balance, null: false, default: 0

      t.datetime :disabled_at
      t.references :disabled_by, type: :uuid, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
