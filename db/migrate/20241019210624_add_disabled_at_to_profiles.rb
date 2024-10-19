class AddDisabledAtToProfiles < ActiveRecord::Migration[7.1]
  def change
    add_column :profiles, :disabled_at, :datetime
    add_reference :profiles, :disabled_by, type: :uuid, foreign_key: { to_table: :users }
  end
end
