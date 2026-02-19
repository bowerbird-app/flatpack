# frozen_string_literal: true

class CreateDemoTableRows < ActiveRecord::Migration[8.0]
  def change
    create_table :demo_table_rows do |t|
      t.string :list_key, null: false
      t.string :name, null: false
      t.string :status, null: false
      t.string :priority, null: false
      t.integer :position, null: false
      t.integer :lock_version, null: false, default: 0

      t.timestamps
    end

    add_index :demo_table_rows, [:list_key, :position], unique: true
  end
end
