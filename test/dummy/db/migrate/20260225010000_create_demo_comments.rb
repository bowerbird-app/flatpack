# frozen_string_literal: true

class CreateDemoComments < ActiveRecord::Migration[8.1]
  def change
    create_table :demo_comments do |t|
      t.references :parent_comment, foreign_key: {to_table: :demo_comments}
      t.string :author_name, null: false
      t.string :author_meta
      t.text :body, null: false
      t.string :state, null: false, default: "default"
      t.datetime :edited_at

      t.timestamps
    end

    add_index :demo_comments, :created_at
    add_index :demo_comments, [:parent_comment_id, :created_at, :id], name: "index_demo_comments_on_parent_and_created"
  end
end
