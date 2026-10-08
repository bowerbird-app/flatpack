# frozen_string_literal: true

class CreateDemoCollectionEditor < ActiveRecord::Migration[8.1]
  def change
    create_table :demo_people do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.timestamps
    end
    add_index :demo_people, :email, unique: true

    create_table :demo_projects do |t|
      t.string :name, null: false
      t.timestamps
    end
    add_index :demo_projects, :name, unique: true

    create_table :demo_project_people do |t|
      t.references :project, null: false, foreign_key: {to_table: :demo_projects}
      t.references :person, null: false, foreign_key: {to_table: :demo_people}
      t.string :role, null: false
      t.integer :position, null: false
      t.timestamps
    end
    add_index :demo_project_people, [:project_id, :person_id], unique: true
    add_index :demo_project_people, [:project_id, :position]
  end
end
