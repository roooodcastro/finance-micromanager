class CreateReconciliationsWallets < ActiveRecord::Migration[7.0]
  def change
    create_table :reconciliations_wallets, type: :uuid do |t|
      t.references :reconciliation, type: :uuid, null: false, index: true, foreign_key: true
      t.references :wallet, type: :uuid, null: false, index: true, foreign_key: true
      t.monetize :balance_amount, null: false, default: 0, currency: { present: false }

      t.timestamps
    end
  end
end
