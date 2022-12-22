class Remote::Application < Remote::Base
  collection_resolver 'data.applications'
  member_resolver 'data'

  has_many :users_credentials, foreign_key: :application_id, class_name: "ApplicationCredential"

  after_save :update_applications_credentials, if: :saved_change_to_connected_applications?

  # TODO: There is probably no need to store the applications connections
  # TODO: Refactor, is the same as Remote::Application
  def update_applications_credentials
    # current_connections = saved_change_to_connected_applications.first
    updated_connections = saved_change_to_connected_applications.last

    updated_connections.each do |connection| 
      credential = ApplicationCredential.find_or_create_by!({ 
        user_id: connection["user_id"], 
        application_id: connection["application_id"]
      }) do |cred|
        cred.auth_type = connection["app_config"]["endpoints"].first["auth"]["type"]
      end
      credential.email = connection["email"]
      credential.encrypted_password = connection["encrypted_password"]
      credential.connected = connection["status"] == "connected"
      credential.save!
    end
  end

  def fetcher 
    if is_observed?
      "#{self.uid.classify}::Fetcher".constantize.new
    else
      NullFetcher.new
    end
  rescue NameError => e
    p "Missing Fetcher for #{self.uid}"
    NullFetcher.new
  end

  def fetch_impact_data! 
    fetcher.fetch_for_users!
  end

  def fetch_impact_data_for_user!(user) 
    fetcher.fetch_for_user!(user)
  end

  # testing prupose
  def test_credentials(user, email, password = nil)
    cred = users_credentials.find_or_initialize_by(email: email, user_id: user.id, connected: true)
    if password
      cred.encode_password(password, force_save: true)
    end
    cred
  end
end
