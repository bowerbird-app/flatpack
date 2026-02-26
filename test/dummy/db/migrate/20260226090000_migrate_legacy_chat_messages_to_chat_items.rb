# frozen_string_literal: true

class MigrateLegacyChatMessagesToChatItems < ActiveRecord::Migration[8.1]
  def up
    migrate_chat_messages_table
    ensure_chat_items_table
    ensure_chat_item_attachments_table
    backfill_item_type
    ensure_chat_item_indexes
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def migrate_chat_messages_table
    return unless table_exists?(:chat_messages)
    return if table_exists?(:chat_items)

    rename_table :chat_messages, :chat_items

    rename_index_if_exists(
      :chat_items,
      "index_chat_messages_on_chat_group_id_and_created_at",
      "index_chat_items_on_chat_group_id_and_created_at"
    )

    rename_index_if_exists(
      :chat_items,
      "index_chat_messages_on_chat_group_id_and_client_temp_id",
      "index_chat_items_on_chat_group_id_and_client_temp_id"
    )

    rename_index_if_exists(
      :chat_items,
      "index_chat_messages_on_chat_group_id",
      "index_chat_items_on_chat_group_id"
    )
  end

  def ensure_chat_items_table
    return if table_exists?(:chat_items)

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
  end

  def ensure_chat_item_attachments_table
    return if table_exists?(:chat_item_attachments)

    create_table :chat_item_attachments do |t|
      t.references :chat_item, null: false, foreign_key: true
      t.string :kind, null: false
      t.string :name, null: false
      t.string :content_type
      t.integer :byte_size
      t.integer :position, null: false, default: 0

      t.timestamps
    end
  end

  def ensure_chat_item_indexes
    add_index :chat_items, [:chat_group_id, :created_at], name: "index_chat_items_on_chat_group_id_and_created_at" unless index_exists?(:chat_items, [:chat_group_id, :created_at], name: "index_chat_items_on_chat_group_id_and_created_at")
    add_index :chat_items, [:chat_group_id, :client_temp_id], name: "index_chat_items_on_chat_group_id_and_client_temp_id" unless index_exists?(:chat_items, [:chat_group_id, :client_temp_id], name: "index_chat_items_on_chat_group_id_and_client_temp_id")
    add_index :chat_items, :item_type, name: "index_chat_items_on_item_type" unless index_exists?(:chat_items, :item_type, name: "index_chat_items_on_item_type")
    add_index :chat_item_attachments, [:chat_item_id, :position], name: "index_chat_item_attachments_on_chat_item_id_and_position" unless index_exists?(:chat_item_attachments, [:chat_item_id, :position], name: "index_chat_item_attachments_on_chat_item_id_and_position")
  end

  def backfill_item_type
    add_column :chat_items, :item_type, :string, null: false, default: "text" unless column_exists?(:chat_items, :item_type)

    change_column_null :chat_items, :body, true if column_exists?(:chat_items, :body)

    execute <<~SQL.squish
      UPDATE chat_items
      SET item_type = CASE
        WHEN body IS NULL OR LENGTH(TRIM(body)) = 0 THEN 'attachment'
        ELSE 'text'
      END
      WHERE item_type IS NULL OR item_type = ''
    SQL
  end

  def rename_index_if_exists(table_name, old_name, new_name)
    return unless index_name_exists?(table_name, old_name)
    return if index_name_exists?(table_name, new_name)

    rename_index table_name, old_name, new_name
  end
end
