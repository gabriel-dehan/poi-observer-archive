class Felix::Fetcher < Fetcher
  spell_url "api/spells/5c8e42d31316059e8a60cadc"

  # TODO: Move to Felix
  def parse_csv(file)
    impact_data = []
    CSV.foreach(file, { headers: true, header_converters: :symbol, col_sep: ';' }) do |row|  
      credential = ApplicationCredential.find_by(email: row[:email], application_id: app.id)
      if credential
        impact_data << { 
          user_id: credential.user_id, 
          data: { 
            distance: row[:distance], 
            transport: "scooter"
          } 
        }
      end
    end

    # Batch transmit to protocol
    transmit_to_protocol(nil, impact_data)
  end

  # TODO: Test & finish
  def transmit_to_protocol(credentials, impact_data)
    puts "Transmited to #{app.uid} protocol"

    response = ::Api::Poi::client.post('/v1/events/batch_emit', {
      "category": app.category,
      "application_id": app.id,
      "user_id": credentials.user_id,
      "data": impact_data
    })  
  end

  # Fetches all impact data for this application for a specific user
  # def fetch_for_user!(user)
  #   credential = user.connected_credentials_for(app.id)
  #   auth_request = credential.generate_auth_request

  #   meta_response = ::Api::Meta.cast(spell, { items: [auth_request] }, async: asynchronous?)

  #   if synchronous?
  #     self.class.handle_response(meta_response)
  #   end
  # end

  # def fetch_for_users!
  #   auth_requests = app.users_credentials.connected.map do |credential|
  #     auth_request = credential.generate_auth_request
  #     auth_request
  #   end

  #   meta_response = ::Api::Meta.cast(spell, { items: auth_requests }, async: asynchronous?)

  #   if synchronous?
  #     self.class.handle_response(meta_response)
  #   end
  # end

  # def transmit_to_protocol(credential, impact_data)
  #   puts "Transmited to #{app.uid} protocol"
    
  #   response = ::Api::Poi::with_auth(credential.user).post('/v1/events', {
  #     "type": "action",
  #     "category": app.category,
  #     "application_id": app.id,
  #     "data": {
  #       "orders": impact_data["orders"]
  #     }
  #   })  
  # end

end