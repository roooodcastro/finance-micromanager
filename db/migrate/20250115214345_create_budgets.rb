class CreateBudgets < ActiveRecord::Migration[7.1]
  def change
    create_table :budgets, id: :uuid do |t|
      t.references :profile, type: :uuid, foreign_key: true, null: false
      t.references :owner, polymorphic: true, type: :uuid, null: false
      t.string :limit_type, limit: 10, null: false
      t.monetize :limit_amount, currency: { present: false }, amount: { null: true, default: nil }
      t.decimal :limit_percentage

      t.datetime :disabled_at
      t.references :disabled_by, type: :uuid, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
