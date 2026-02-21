# frozen_string_literal: true

class CreateDummyData < ActiveRecord::Migration[8.1]
  def change
    create_table :dummy_data do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :status, null: false
      t.string :category, null: false
      t.integer :views_count, null: false, default: 0
      t.integer :position, null: false
      t.datetime :published_at, null: false
      t.integer :lock_version, null: false, default: 0

      t.timestamps
    end

    add_index :dummy_data, [:status, :published_at]
    add_index :dummy_data, [:category, :published_at]
    add_index :dummy_data, :position, unique: true
    add_index :dummy_data, :email, unique: true
  end
end
