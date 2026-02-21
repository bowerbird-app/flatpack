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

ActiveRecord::Schema[8.1].define(version: 2026_02_21_000000) do
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
end
