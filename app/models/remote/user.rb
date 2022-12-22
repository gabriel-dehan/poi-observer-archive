class Remote::User < Remote::Base
  collection_resolver 'data'
  member_resolver 'data'

  has_many :application_credentials, foreign_key: :user_id

  after_save :update_applications_credentials, if: :saved_change_to_connected_applications?

  def cache!(remote_record)
    # We set even the id
    fields = remote_record.slice(*self.class.cached_attributes_names)

    if remote_record[:internal_token]
      fields[:internal_token] = Base64.encode64(remote_record[:internal_token])
    else
      # Make sure we don't override the internal_token with a nil value
      fields.delete(:internal_token)
    end

    self.assign_attributes(fields)
    self.mark_as_cached
    self.save!
  end

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

  def connected_credentials_for(application_id)
    self.application_credentials.connected.find_by(application_id: application_id)
  end

  def fetch_impact_data!(application = nil)
    if application 
      credential = connected_credentials_for(application.id)
      if credential
        application.fetcher.fetch_for_user!(self)
      else
        raise ArgumentError.new("User #{self.id} is not connected to the application #{application.id}")
      end
    else
      apps_ids = application_credentials.connected.pluck(:application_id)

      # find_all makes sure cache is not stale, I couldn't override where
      applications = Remote::Application.find_all.where(id: apps_ids)

      applications.each do |application|
        application.fetcher.fetch_for_user!(self)
      end
    end
  end
end
