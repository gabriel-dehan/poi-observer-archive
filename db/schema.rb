# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_05_14_145435) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "application_credentials", force: :cascade do |t|
    t.bigint "application_id"
    t.bigint "user_id"
    t.string "email"
    t.text "encrypted_password"
    t.string "auth_type"
    t.json "auth", default: {"token"=>nil, "refresh_token"=>nil, "expires_at"=>nil}
    t.json "last_requests", default: []
    t.datetime "last_fetched"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "connected", default: true, null: false
    t.jsonb "metadata", default: {}
  end

  create_table "remote_applications", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid"
    t.string "category", null: false
    t.boolean "is_observed", default: true, null: false
    t.json "config", default: {}
    t.json "connected_applications", default: []
    t.datetime "last_cached_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "remote_cache_policies", force: :cascade do |t|
    t.integer "users_cache_duration"
    t.datetime "users_last_cached_at"
    t.integer "applications_cache_duration"
    t.datetime "applications_last_cached_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "remote_users", force: :cascade do |t|
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "full_name"
    t.string "email", null: false
    t.string "referrer_code"
    t.string "referral_code"
    t.json "tokens"
    t.json "connected_applications", default: []
    t.json "settings", default: {}
    t.string "phone_number"
    t.boolean "admin", default: false, null: false
    t.datetime "last_cached_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "internal_token"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
