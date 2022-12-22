module Api::Poi 
  LOCAL = Rails.env.development? 

  def self.client(local = Api::Poi::LOCAL)
    @client ||= Api::Base::Client.new(connection(local))
  end

  def self.with_auth(user, local = Api::Poi::LOCAL) 
    @auth_client ||= Api::Base::Client.new(connection(local, with_auth: true, user: user))
  end

  def self.connection(local, with_auth: false, user: nil)
    @connection ||= Faraday.new(url: local ? "http://localhost:3000/v1" : ENV["BASE_API_URL"]) do |connection|
      connection.use :instrumentation
      
      connection.request :json
      connection.basic_auth('poi-observer', ENV['INTERNAL_API_PRIVATE_KEY'])

      # TODO: Unstable internal_token system, needs improvements
      if with_auth && user
        connection.headers['token-type'] = 'Bearer'
        connection.headers['access-token'] = Base64.decode64(user.internal_token)
        connection.headers['uid'] = user.email
        connection.headers['client'] = "poi-internal"
      end

      connection.response :logger
      connection.response :json, :content_type => /\bjson$/

      connection.adapter  Faraday.default_adapter
    end
  end

  def self.users
    Api::Poi::client.get("/v1/users").body[:data][:users]
  end

  def self.user(id)
    Api::Poi::client.get("/v1/users/#{id}").body[:data]
  end
end