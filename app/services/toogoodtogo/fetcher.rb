class Toogoodtogo::Fetcher < Fetcher
  spell_url "api/spells/5c9949598385b2058ae6158a"

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