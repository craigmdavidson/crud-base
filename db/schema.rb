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

ActiveRecord::Schema[8.0].define(version: 2026_03_15_105618) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "city"
    t.string "state_or_province"
    t.string "postal_code"
    t.string "country"
    t.string "external_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "post_id", null: false
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_comments_on_post_id"
  end

  create_table "funds", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.string "name"
    t.string "code"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.money "total_fund", scale: 2
    t.money "research_allocation", scale: 2
    t.money "operations_expense_allocation", scale: 2
    t.money "program_delivery_allocation", scale: 2
    t.index ["organization_id"], name: "index_funds_on_organization_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "messagable_type", null: false
    t.bigint "messagable_id", null: false
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["messagable_type", "messagable_id"], name: "index_messages_on_messagable"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.bigint "address_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "code"
    t.string "business_number"
    t.string "legal_name"
    t.string "trading_name"
    t.index ["address_id"], name: "index_organizations_on_address_id"
  end

  create_table "people", force: :cascade do |t|
    t.string "title"
    t.string "first_name"
    t.string "last_name"
    t.bigint "address_id"
    t.string "email"
    t.string "telephone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "organization_id"
    t.index ["address_id"], name: "index_people_on_address_id"
    t.index ["organization_id"], name: "index_people_on_organization_id"
  end

  create_table "posts", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "person_id"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["person_id"], name: "index_users_on_person_id"
  end

  add_foreign_key "comments", "posts"
  add_foreign_key "funds", "organizations"
  add_foreign_key "messages", "users"
  add_foreign_key "organizations", "addresses"
  add_foreign_key "people", "addresses"
  add_foreign_key "people", "organizations"
  add_foreign_key "posts", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "users", "people"
end
