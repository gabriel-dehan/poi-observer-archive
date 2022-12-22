class Goodeed::Authentifier < Authentifier
  def initialize(credential)
    super
    @request_uuid = SecureRandom.uuid
  end

  def request
    Goodeed::Api.client.post("", {
      "#{@request_uuid}": {
        module: "session",
        action: "login",
        email: credential.email,
        password: credential.password
      }
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
      data = response.body

      return false if !response.success? || data[@request_uuid]["error"].present?
      
      cookies = CGI::Cookie.parse(response.headers["set-cookie"])

      sid = cookies["goodeed.sid"].first
      expires_at = cookies["Expires"].first

      user = data[@request_uuid]

      auth = credential.auth 
      auth["token"] = user[:accessToken]
      auth["expires_at"] = (expires_at ? DateTime.parse(expires_at).utc : DateTime.now.utc + 12.hours)
      auth["cookie"] = sid

      credential.update({ auth: auth })
    end
    
    {
      token: credential.auth["token"],
      cookie: credential.auth["cookie"]
    }
  end
end