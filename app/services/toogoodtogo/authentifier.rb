class Toogoodtogo::Authentifier < Authentifier
  def request
    Toogoodtogo::Api.client.post("login", {
      email: credential.email,
      password: credential.password,
    })
  end

  # TODO: After 1h force refresh
  def token_invalid?
    !(credential.auth["user_token"] && credential.auth["user_id"])
  end

  def get_auth!  
    # If we don't have the distant password stored, we store it in the cache db
    # TODO: Handle cache clear if password changed
    if token_invalid?
      response = request
      user = response.body

      return false unless response.success?

      auth = credential.auth 
      auth["user_id"] = user[:user_id]
      auth["user_token"] = user[:user_token]        

      credential.update({ auth: auth })
    end
    
    {
      user_id: credential.auth["user_id"],
      user_token: credential.auth["user_token"]
    }
  end

end