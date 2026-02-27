# frozen_string_literal: true

class CreateChatGroupsAndChatMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :chat_groups do |t|
      t.string :name, null: false

      t.timestamps
    end

    create_table :chat_items do |t|
      t.references :chat_group, null: false, foreign_key: true
      t.string :sender_name, null: false
      t.text :body
      t.string :state, null: false, default: "sent"
      t.string :item_type, null: false, default: "text"
      t.string :client_temp_id
      t.datetime :submitted_at

      t.timestamps
    end

    create_table :chat_item_attachments do |t|
      t.references :chat_item, null: false, foreign_key: true
      t.string :kind, null: false
      t.string :name, null: false
      t.string :content_type
      t.integer :byte_size
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :chat_items, [:chat_group_id, :created_at]
    add_index :chat_items, [:chat_group_id, :client_temp_id]
    add_index :chat_items, :item_type
    add_index :chat_item_attachments, [:chat_item_id, :position]
  end
end
