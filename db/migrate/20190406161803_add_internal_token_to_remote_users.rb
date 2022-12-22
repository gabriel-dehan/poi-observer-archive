class AddInternalTokenToRemoteUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :remote_users, :internal_token, :string
  end
end
