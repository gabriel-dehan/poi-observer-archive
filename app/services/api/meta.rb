module Api::Meta 
  class Error < StandardError; end 

  class << self 
    def client(credentials = nil)
      if credentials 
        @authfull_client = Api::Base::Client.new(connection(credentials))
      else  
        @authless_client ||= Api::Base::Client.new(connection)
      end
    end

    def connection(credentials = nil)
      Faraday.new(ENV['META_API_URL']) do |connection|
        connection.use :instrumentation
        
        connection.request :json
        
        connection.headers['token-type'] = 'Bearer'
        connection.headers['apikey'] = 'bK7MEvtAiclK0VSz9EG83lnEtYvKMBFJ'

        connection.response :logger
        connection.response :json, :content_type => /\bjson$/

        connection.adapter  Faraday.default_adapter
      end
    end

    def cast(url, options = {}, async: false, has_dev: false)
      if has_dev
        default_options = { dev: Rails.env.development? }
      else
        default_options = {}
      end
      if async
        # add the callback url so meta knows what it needs to send us
        default_options[:callbackUrl] = ENV['META_WEBHOOK_URL']
      end
      # Adds /runAsync or /runSync as necessary
      url += async ? 'runAsync' : 'runSync'

      if Rails.env.development? || ENV['DEBUG_MODE']
        puts "== META API REQUEST OPTIONS DEBUG =="
        p options.merge(default_options)
      end
      Api::Base::Response.new(client.connection.post(url, options.merge(default_options)))
    end
  
  end

  # Gives rails params an interface close to an Api::Base::Response
  class AsyncResponse 
    def initialize(params)
      @params = params
      if params[:spellResult]
        @success = true 
      end
    end

    def status 
      @success ? 200 : 500
    end

    def body 
      { 
        data: @params[:spellResult]
      }
    end

    def success?
      @success 
    end

  end
end