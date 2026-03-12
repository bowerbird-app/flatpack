# frozen_string_literal: true

class CreateArticles < ActiveRecord::Migration[8.0]
  def change
    create_table :articles do |t|
      t.string :title, null: false
      t.text :body
      t.string :body_format, default: "html", null: false
      t.timestamps
    end
  end
end
