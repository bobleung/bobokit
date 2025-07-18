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

ActiveRecord::Schema[8.0].define(version: 2025_07_16_042221) do
  create_table "jobs", force: :cascade do |t|
    t.datetime "start", null: false
    t.datetime "end", null: false
    t.integer "break_minutes"
    t.datetime "actual_start"
    t.datetime "actual_end"
    t.integer "actual_break_minutes"
    t.integer "client_pays"
    t.integer "locum_gets"
    t.integer "agency_gets"
    t.text "notes_job"
    t.text "notes_client"
    t.text "notes_agency"
    t.integer "agency_id"
    t.integer "client_id", null: false
    t.integer "locum_id"
    t.string "owned_by", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agency_id"], name: "index_jobs_on_agency_id"
    t.index ["client_id"], name: "index_jobs_on_client_id"
    t.index ["end"], name: "index_jobs_on_end"
    t.index ["locum_id"], name: "index_jobs_on_locum_id"
    t.index ["owned_by"], name: "index_jobs_on_owned_by"
    t.index ["start"], name: "index_jobs_on_start"
  end

  create_table "memberships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "entity_id", null: false
    t.integer "role", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "invited_email"
    t.boolean "invite_accepted", default: false
    t.index ["entity_id"], name: "index_memberships_on_entity_id"
    t.index ["invited_email"], name: "index_memberships_on_invited_email"
    t.index ["user_id", "entity_id"], name: "index_memberships_on_user_id_and_entity_id", unique: true
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "organisations", force: :cascade do |t|
    t.string "type", null: false
    t.string "name", null: false
    t.string "email"
    t.string "phone"
    t.string "address_line1"
    t.string "address_line2"
    t.string "city"
    t.string "county"
    t.string "postcode"
    t.string "country"
    t.json "metadata"
    t.integer "parent_id"
    t.string "code_type"
    t.string "code"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true, null: false
    t.index ["parent_id"], name: "index_organisations_on_parent_id"
    t.index ["type"], name: "index_organisations_on_type"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
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
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.datetime "email_verified_at"
    t.string "verification_token"
    t.datetime "verification_token_expires_at"
    t.boolean "super_admin", default: false
    t.boolean "deactivated", default: false, null: false
    t.index ["deactivated"], name: "index_users_on_deactivated"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["verification_token"], name: "index_users_on_verification_token", unique: true
  end

  add_foreign_key "jobs", "organisations", column: "agency_id"
  add_foreign_key "jobs", "organisations", column: "client_id"
  add_foreign_key "jobs", "organisations", column: "locum_id"
  add_foreign_key "memberships", "organisations", column: "entity_id"
  add_foreign_key "memberships", "users"
  add_foreign_key "organisations", "organisations", column: "parent_id"
  add_foreign_key "sessions", "users"
end
