# frozen_string_literal: true

class CreateChatGroupsAndChatMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :chat_groups do |t|
      t.string :name, null: false

      t.timestamps
    end

    create_table :chat_messages do |t|
      t.references :chat_group, null: false, foreign_key: true
      t.string :sender_name, null: false
      t.text :body, null: false
      t.string :state, null: false, default: "sent"
      t.string :client_temp_id
      t.datetime :submitted_at

      t.timestamps
    end

    add_index :chat_messages, [:chat_group_id, :created_at]
    add_index :chat_messages, [:chat_group_id, :client_temp_id]
  end
end
