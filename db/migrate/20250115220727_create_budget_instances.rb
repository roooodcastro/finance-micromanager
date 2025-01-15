class CreateBudgetInstances < ActiveRecord::Migration[7.1]
  def change
    create_table :budget_instances, id: :uuid do |t|
      t.references :profile, type: :uuid, foreign_key: true, null: false
      t.references :owner, polymorphic: true, type: :uuid, null: false
      t.string :limit_type, limit: 10, null: false
      t.monetize :limit_amount, currency: { present: false }, amount: { null: true, default: nil }
      t.decimal :limit_percentage

      t.monetize :used_amount, currency: { present: false }, amount: { null: false, default: 0 }
      t.datetime :start_date, null: false
      t.datetime :end_date, null: false
      t.references :budget

      t.timestamps
    end
  end
end
