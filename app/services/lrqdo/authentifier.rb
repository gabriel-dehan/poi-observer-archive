class Lrqdo::Authentifier < Authentifier
  def request 
    Lrqdo::Api.client.post("oauth/v2/token", {
      "grant_type":"password",
      "client_id":"1_52orz4s96icc88k8ocs4ogcog88w8co4scckkcog0404w004o8",
      "username": credential.email,
      "password": credential.password
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
    # TODO: Handle cache clear if password changed
    # Handle refresh token and access token

    # If we don't have the distant password stored, we store it in the cache db
    if token_invalid? 
      response = request
      user = response.body

      # Returns false if there is an issue
      return false unless response.success?

      auth = credential.auth 
      auth["token"] = user[:access_token]
      auth["refresh_token"] = user[:refresh_token]
      auth["expires_at"] = (Time.now + user[:expires_in]).utc.to_datetime

      credential.update({ auth: auth })
    end
    
    {
      token: credential.auth["token"]
    }
  end

end