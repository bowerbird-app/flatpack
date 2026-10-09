# frozen_string_literal: true

class CreateDemoGalleryImages < ActiveRecord::Migration[8.1]
  def change
    create_table :demo_images do |t|
      t.string :name, null: false
      t.string :alt_text, null: false
      t.string :swatch, null: false
      t.timestamps
    end
    add_index :demo_images, :name, unique: true

    create_table :demo_project_images do |t|
      t.references :project, null: false, foreign_key: {to_table: :demo_projects}
      t.references :image, null: false, foreign_key: {to_table: :demo_images}
      t.string :caption
      t.string :credit
      t.integer :position, null: false
      t.timestamps
    end
    add_index :demo_project_images, [:project_id, :image_id], unique: true
    add_index :demo_project_images, [:project_id, :position]
  end
end
