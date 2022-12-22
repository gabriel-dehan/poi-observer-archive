class AddMetaDataToApplicationCredentials < ActiveRecord::Migration[5.2]
  def change
    add_column :application_credentials, :metadata, :jsonb, default: {}
  end
end
