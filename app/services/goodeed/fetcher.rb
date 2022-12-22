class Goodeed::Fetcher < Fetcher
  spell_url "api/spells/5c9a65e2647f63e50ac3bee3"
  formatter ->(data, credential) do
    if data["userData"] && data["userData"]["supportedProjects"]
      donations = data["userData"]["supportedProjects"]
        .map { |project| project["free_donations"] }
        .sum
    else
      donations = 0
    end

    { 
      total_donations: donations
    }
  end

  def transmit_to_protocol(credential, impact_data)
    puts "Transmited to #{app.uid} protocol"
    # TODO: Maybe refactor, same as lilo
    prev_data = credential.metadata["previous_impact_data"]

    if prev_data && prev_data["total_donations"] < impact_data["total_donations"]
      # Only send the difference

      response = ::Api::Poi::client.post('/v1/events', {
        "type": "action",
        "category": app.category,
        "application_id": app.id,
        "user_id": credential.user_id,
        "data": {
          total_donations: impact_data["total_donations"] - prev_data["total_donations"]
        }
      })  
    end
    # else -> If there was no previous data we don't transmit to protocol 
    # because we need to build the previous data for future diffs

  end

end