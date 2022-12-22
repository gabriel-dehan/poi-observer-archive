class Blablacar::Fetcher < Fetcher
  spell_url "api/spells/5c8e42d31316059e8a60cadc"

  # def cast_batch_spell(auth_requests, options = {})
  #   # if auth is false or nil we remove it
  #   auth_requests.reject! { |auth| !auth }

  #   if auth_requests.any?
  #     auth_requests.each do |request| 
  #       meta_response = ::Api::Meta.cast(spell, request, options.merge({ async: asynchronous? }))

  #       if synchronous?
  #         self.class.handle_response(meta_response)
  #       end
  #     end
  #   end
  # end

  # TODO: Reactivate the lastSync
  
  def transmit_to_protocol(credentials, impact_data)
    puts "Transmited to #{app.uid} protocol"

    if impact_data["payments"].any?
      data = { 
        distance: impact_data["payments"].map { |payment| payment["distance"]["value"] }.sum / 1000.0,
        transport: 'carpool'
      }

      response = ::Api::Poi::client.post('/v1/events', {
        "type": "action",
        "category": app.category,
        "application_id": app.id,
        "user_id": credentials.user_id,
        "data": data
      })  
    end
  end

end