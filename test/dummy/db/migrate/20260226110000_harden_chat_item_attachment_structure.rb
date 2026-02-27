# frozen_string_literal: true

class HardenChatItemAttachmentStructure < ActiveRecord::Migration[8.1]
  def up
    add_column :chat_items, :attachments_count, :integer, null: false, default: 0 unless column_exists?(:chat_items, :attachments_count)

    unless column_exists?(:chat_item_attachments, :storage_key)
      add_column :chat_item_attachments, :storage_key, :string
    end

    unless column_exists?(:chat_item_attachments, :checksum)
      add_column :chat_item_attachments, :checksum, :string
    end

    unless column_exists?(:chat_item_attachments, :metadata)
      add_column :chat_item_attachments, :metadata, :json, null: false, default: {}
    end

    unless check_constraint_exists?(:chat_items, name: "chat_items_attachments_count_non_negative")
      add_check_constraint :chat_items,
        "attachments_count >= 0",
        name: "chat_items_attachments_count_non_negative"
    end

    unless check_constraint_exists?(:chat_item_attachments, name: "chat_item_attachments_position_non_negative")
      add_check_constraint :chat_item_attachments,
        "position >= 0",
        name: "chat_item_attachments_position_non_negative"
    end

    unless check_constraint_exists?(:chat_item_attachments, name: "chat_item_attachments_byte_size_non_negative")
      add_check_constraint :chat_item_attachments,
        "byte_size IS NULL OR byte_size >= 0",
        name: "chat_item_attachments_byte_size_non_negative"
    end

    unless check_constraint_exists?(:chat_item_attachments, name: "chat_item_attachments_kind_allowed")
      add_check_constraint :chat_item_attachments,
        "kind IN ('image', 'file')",
        name: "chat_item_attachments_kind_allowed"
    end

    backfill_attachments_count!
  end

  def down
    remove_check_constraint :chat_item_attachments, name: "chat_item_attachments_kind_allowed" if check_constraint_exists?(:chat_item_attachments, name: "chat_item_attachments_kind_allowed")
    remove_check_constraint :chat_item_attachments, name: "chat_item_attachments_byte_size_non_negative" if check_constraint_exists?(:chat_item_attachments, name: "chat_item_attachments_byte_size_non_negative")
    remove_check_constraint :chat_item_attachments, name: "chat_item_attachments_position_non_negative" if check_constraint_exists?(:chat_item_attachments, name: "chat_item_attachments_position_non_negative")
    remove_check_constraint :chat_items, name: "chat_items_attachments_count_non_negative" if check_constraint_exists?(:chat_items, name: "chat_items_attachments_count_non_negative")

    remove_column :chat_item_attachments, :metadata if column_exists?(:chat_item_attachments, :metadata)
    remove_column :chat_item_attachments, :checksum if column_exists?(:chat_item_attachments, :checksum)
    remove_column :chat_item_attachments, :storage_key if column_exists?(:chat_item_attachments, :storage_key)
    remove_column :chat_items, :attachments_count if column_exists?(:chat_items, :attachments_count)
  end

  private

  def backfill_attachments_count!
    execute <<~SQL.squish
      UPDATE chat_items
      SET attachments_count = (
        SELECT COUNT(*)
        FROM chat_item_attachments
        WHERE chat_item_attachments.chat_item_id = chat_items.id
      )
    SQL
  end
end
