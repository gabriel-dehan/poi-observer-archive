class Dreamact::Fetcher < Fetcher
  spell_url "api/spells/5ccc0af18e896e32f33e332b"

  def transmit_to_protocol(credentials, impact_data)
    puts "Transmited to #{app.uid} protocol"

    if impact_data["transactions"].any?
      response = ::Api::Poi::client.post('/v1/events', {
        "type": "action",
        "category": app.category,
        "application_id": app.id,
        "user_id": credentials.user_id,
        "data": { transactions: impact_data["transactions"] }
      })  
    end
  end

end