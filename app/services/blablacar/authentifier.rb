class Blablacar::Authentifier < Authentifier
  def request
    Blablacar::Api.client.post("/token", {
      login: credential.email,
      password: credential.password,
      grant_type: "password",
      client_id: "members",
      client_secret: "6kG4PB6Yf0VBBtfuF5y9EbXzyLAPXrl2MTnFJRDoOTGDqGuBGUcT3FWhL82wW1Ar",
      scopes: [
        "BLABLACAR_MEMBER_PRIVILEGE",
        "ROLE_TRIP_DRIVER",
        "ROLE_CLIENT_TRUSTED",
        "ROLE_CLIENT_USER",
        "SCOPE_USER_INFO_PERSO",
        "SCOPE_TRIP_DRIVER",
        "SCOPE_USER_MESSAGING",
        "SCOPE_INTERNAL_CLIENT",
        "DEFAULT"
      ]
    })
  end

  def token_invalid?
    if credential.auth["token"] && credential.auth["expires_at"]
      DateTime.now.utc >= DateTime.parse(credential.auth["expires_at"])
    else 
      true
    end
  end

  def get_auth!      
    # If we don't have the distant password stored, we store it in the cache db

    # TODO: Handle cache clear if password changed
    # Handle refresh token and access token
    if token_invalid?
      response = request
      user = response.body

      return false unless response.success?
      
      auth = credential.auth 
      auth["token"] = user[:access_token]
      auth["refresh_token"] = user[:refresh_token]
      auth["expires_at"] = (Time.at(user[:issued_at]) + user[:expires_in]).utc.to_datetime

      credential.update({ auth: auth })
    end
    
    {
      token: credential.auth["token"]
    }
  end
end