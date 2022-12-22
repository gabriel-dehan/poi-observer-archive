

class CreateRemoteCachePolicies < ActiveRecord::Migration[5.2]
  def change
    create_table :remote_cache_policies do |t|
      t.integer :users_cache_duration
      t.datetime :users_last_cached_at

      t.integer :applications_cache_duration
      t.datetime :applications_last_cached_at
      
      t.timestamps
    end
  end
end
