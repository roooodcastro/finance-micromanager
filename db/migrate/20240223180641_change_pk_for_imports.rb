class ChangePkForImports < ActiveRecord::Migration[7.1]
  def change
    remove_reference :transactions, :import

    add_column :imports, :uuid, :uuid, default: "gen_random_uuid()", null: false

    change_table :imports do |t|
      t.remove :id
      t.rename :uuid, :id
    end

    execute 'ALTER TABLE imports ADD PRIMARY KEY (id);'

    add_reference :transactions, :import, index: true, foreign_key: true, type: :uuid
  end
end
