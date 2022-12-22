class Lilo::Authentifier < Authentifier

  def request
    Lilo::Api.client.post("", {
      action: "actionLoginLilo",
      login: credential.email,
      password: credential.password
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
    if token_invalid?
      response = request
      user = JSON.parse(response.body)

      return false unless response.success? || user["status"] == "ko"
      
      auth = credential.auth 
      auth["token"] = user["userkey"]
      # TODO: Check manually when lilo tokens tend to expire
      auth["expires_at"] = DateTime.now.utc + 12.hours 

      credential.update({ auth: auth })
    end
    
    {
      token: credential.auth["token"],
    }
  end
end