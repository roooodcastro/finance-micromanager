class CreateCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :categories, id: :uuid do |t|
      t.string :name, limit: 50, null: false
      t.string :color, limit: 6
      t.references :account, type: :uuid, null: false, index: true, foreign_key: true
      t.datetime :disabled_at

      t.timestamps
    end
  end
end
