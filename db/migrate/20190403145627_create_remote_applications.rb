class CreateRemoteApplications < ActiveRecord::Migration[5.2]
  def change
    create_table :remote_applications do |t|
      t.string "name", null: false
      t.string "uid"
      t.string "category", null: false
      t.boolean "is_observed", default: true, null: false
      t.json "config", default: {}
      t.json "connected_applications", default: []
      t.datetime "last_cached_at", null: false

      t.timestamps
    end
  end
end
