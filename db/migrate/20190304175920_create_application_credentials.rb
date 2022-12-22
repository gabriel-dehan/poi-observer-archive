class CreateApplicationCredentials < ActiveRecord::Migration[5.2]
  def change
    create_table :application_credentials do |t|
      t.bigint :application_id 
      t.bigint :user_id 
      t.string :email 
      t.text :encrypted_password
      t.string :auth_type 
      t.json :auth, default: {
        token: nil, 
        refresh_token: nil, 
        expires_at: nil
      }
      t.json :last_requests, default: []
      t.datetime :last_fetched

      t.timestamps
    end
  end
end
