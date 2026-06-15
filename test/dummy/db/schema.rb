# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_13_021057) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "articles", force: :cascade do |t|
    t.text "body"
    t.string "body_format", default: "html", null: false
    t.datetime "created_at", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
  end

  create_table "chat_groups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "chat_item_attachments", force: :cascade do |t|
    t.integer "byte_size"
    t.integer "chat_item_id", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "kind", null: false
    t.json "metadata", default: {}, null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.string "storage_key"
    t.datetime "updated_at", null: false
    t.index ["chat_item_id", "position"], name: "index_chat_item_attachments_on_chat_item_id_and_position"
    t.index ["chat_item_id"], name: "index_chat_item_attachments_on_chat_item_id"
    t.check_constraint "byte_size IS NULL OR byte_size >= 0", name: "chat_item_attachments_byte_size_non_negative"
    t.check_constraint "kind IN ('image', 'file')", name: "chat_item_attachments_kind_allowed"
    t.check_constraint "position >= 0", name: "chat_item_attachments_position_non_negative"
  end

  create_table "chat_items", force: :cascade do |t|
    t.integer "attachments_count", default: 0, null: false
    t.text "body"
    t.integer "chat_group_id", null: false
    t.string "client_temp_id"
    t.datetime "created_at", null: false
    t.string "item_type", default: "text", null: false
    t.string "sender_name", null: false
    t.string "state", default: "sent", null: false
    t.datetime "submitted_at"
    t.datetime "updated_at", null: false
    t.index ["chat_group_id", "client_temp_id"], name: "index_chat_items_on_chat_group_id_and_client_temp_id"
    t.index ["chat_group_id", "created_at"], name: "index_chat_items_on_chat_group_id_and_created_at"
    t.index ["chat_group_id"], name: "index_chat_items_on_chat_group_id"
    t.index ["item_type"], name: "index_chat_items_on_item_type"
    t.check_constraint "attachments_count >= 0", name: "chat_items_attachments_count_non_negative"
  end

  create_table "demo_comments", force: :cascade do |t|
    t.string "author_meta"
    t.string "author_name", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "edited_at"
    t.integer "parent_comment_id"
    t.string "state", default: "default", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_demo_comments_on_created_at"
    t.index ["parent_comment_id", "created_at", "id"], name: "index_demo_comments_on_parent_and_created"
    t.index ["parent_comment_id"], name: "index_demo_comments_on_parent_comment_id"
  end

  create_table "demo_table_rows", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "list_key", null: false
    t.integer "lock_version", default: 0, null: false
    t.string "name", null: false
    t.integer "position", null: false
    t.string "priority", null: false
    t.string "status", null: false
    t.datetime "updated_at", null: false
    t.index ["list_key", "position"], name: "index_demo_table_rows_on_list_key_and_position", unique: true
  end

  create_table "dummy_data", force: :cascade do |t|
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.integer "lock_version", default: 0, null: false
    t.string "name", null: false
    t.integer "position", null: false
    t.datetime "published_at", null: false
    t.string "status", null: false
    t.datetime "updated_at", null: false
    t.integer "views_count", default: 0, null: false
    t.index ["category", "published_at"], name: "index_dummy_data_on_category_and_published_at"
    t.index ["email"], name: "index_dummy_data_on_email", unique: true
    t.index ["position"], name: "index_dummy_data_on_position", unique: true
    t.index ["status", "published_at"], name: "index_dummy_data_on_status_and_published_at"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "chat_item_attachments", "chat_items"
  add_foreign_key "chat_items", "chat_groups"
  add_foreign_key "demo_comments", "demo_comments", column: "parent_comment_id"
end
