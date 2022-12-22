class AddConnectedToApplicationCredentials < ActiveRecord::Migration[5.2]
  def change
    add_column :application_credentials, :connected, :boolean, default: true, null: false
  end
end
