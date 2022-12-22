class Phenix::Authentifier < Authentifier
  def request
    Phenix::Api.client.post("/api/consumer/login", {
      username: credential.email, 
      password: credential.password
    })
  end

  # TODO: After 1h force refresh
  def token_invalid? 
    !credential.auth["remote_encrypted_password"]  
  end

  def get_auth!
    # If we don't have the distant password stored, we store it in the cache db
    # TODO: Handle cache clear if password changed
    if token_invalid?
      response = request
      user = response.body
      
      # Returns false if there is an issue
      return false unless response.success?

      auth = credential.auth 
      auth["remote_encrypted_password"] = user[:password]
      credential.update({ auth: auth })
    end

    {
      token: Phenix::Api.generate_wsse_headers(credential)
    }
  end

end