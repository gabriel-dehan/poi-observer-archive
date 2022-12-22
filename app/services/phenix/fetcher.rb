class Phenix::Fetcher < Fetcher
  spell_url "api/spells/5c803d523fc97fae8b541b8b"

  def fetch_for_user!(user)
    credential = user.connected_credentials_for(app.id)
    auth_request = credential.generate_auth_request

    cast_batch_spell([auth_request], has_dev: true)
  end

  def fetch_for_users!
    auth_requests = app.users_credentials.connected.map do |credential|
      auth_request = credential.generate_auth_request
      auth_request
    end

    cast_batch_spell(auth_requests, has_dev: true)
  end

  def transmit_to_protocol(credentials, impact_data)
    puts "Transmited to #{app.uid} protocol"
    
    if impact_data["orders"].any?
      response = ::Api::Poi::client.post('/v1/events', {
        "type": "action",
        "category": app.category,
        "application_id": app.id,
        "user_id": credentials.user_id,
        "data": {
          "orders": impact_data["orders"]
        }
      })  
    end
  end

end