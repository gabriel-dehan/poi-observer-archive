class Lilo::Fetcher < Fetcher
  limit 6.hours
  spell_url "api/spells/5cbcab9ec0d70754b7cbe056"
  formatter ->(data, credential) do
    { 
      total_drops: data["dropsTotal"] 
    }
  end

  def transmit_to_protocol(credential, impact_data)
    puts "Transmited to #{app.uid} protocol"
    # TODO: Maybe refactor, same as goodeed
    prev_data = credential.metadata["previous_impact_data"]

    if prev_data && prev_data["total_drops"] < impact_data["total_drops"]
      response = ::Api::Poi::client.post('/v1/events', {
        "type": "action",
        "category": app.category,
        "application_id": app.id,
        "user_id": credential.user_id,
        "data": { # Only send the difference
          total_drops: impact_data["total_drops"] - prev_data["total_drops"]
        }
      })     
    end
    # TODO: Improve, this data should be cached after a connect
    # else -> If there was no previous data we don't transmit to protocol 
    # because we need to build the previous data for future diffs

  end

end