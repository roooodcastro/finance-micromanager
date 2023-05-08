# frozen_string_literal: true

class CreateImports < ActiveRecord::Migration[7.0]
  def change
    create_table :imports do |t|
      t.string :source, null: false, limit: 10

      t.timestamps
    end
  end
end
