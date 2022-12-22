module Api::Base
  class Client 
    attr_reader :connection
    def initialize(connection)
      @connection = connection
    end

    def get(url, data = nil, &block)
      Api::Base::Response.new(@connection.get(url, data, block))
    end

    def post(url, data = nil, &block)

      if @connection.headers["Content-Type"] == 'application/x-www-form-urlencoded'
        data = URI.encode_www_form(data)
      end
      Api::Base::Response.new(@connection.post(url, data, block))
    end
  end 

  class Response 
    attr_reader :faraday 

    delegate :status, to: :faraday
    delegate :headers, to: :faraday

    def initialize(response)
      @faraday = response 
    end

    def success? 
      [200, 201, 202, 203, 204, 205, 206, 207, 226].include? status
    end

    def body 
      p @faraday.body if Rails.env.development?

      if @faraday.body.kind_of? Hash
        @faraday.body.with_indifferent_access
      else  
        @faraday.body 
      end
    end
    alias_method :data, :body
  end

  # Included in children
  module Connection 
    def client(credentials = nil)
      if credentials 
        @authfull_client = Api::Base::Client.new(connection(credentials))
      else  
        @authless_client = Api::Base::Client.new(connection)
      end
    end

    def connection(credentials = nil)
      create_connection(@base_url, credentials, &@connection_modifier)
    end

    def set_connection(url, block)
      @base_url = url 
      @connection_modifier = block 
    end

    def create_connection(base_url, credentials = nil, &block)  
      @connection = Faraday.new(base_url) do |connection|
        connection.use :instrumentation
        
        connection.request :json

        connection.response :logger
        connection.response :json, :content_type => /\bjson$/

        connection.adapter  Faraday.default_adapter

        # Setup headers and other things
        block.call(credentials, connection) if block_given? 
      end
    end
  end

end