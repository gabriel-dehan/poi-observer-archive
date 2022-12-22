class CreateRemoteUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :remote_users do |t|
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
      t.datetime :last_cached_at, null: false

      t.timestamps
    end
  end
end
