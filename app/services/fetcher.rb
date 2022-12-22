# Must be inherited by an Application Fetcher class. EG: Phoenix::Fetcher < Fetcher 
# The name of the fetcher must be `application.uid.classify`

class Fetcher 
  # TODO: Refactor / clean up
  attr_reader :app

  class << self 
    def asynchronous?
      (ENV['META_FORCE_ASYNC'] == "true") || Rails.env.production? 
    end

    def synchronous?
      !asynchronous?
    end

    def spell_url(spell_url)
      @spell_url = spell_url
    end

    def limit(timespan)
      @limit = timespan
    end

    # Allows data transformations before saving the request data in credentials.
    # Also, the data is transmitted to the procotol after passing through the formatter
    # Can also be used when you need to format the data for computations
    def formatter(proc)
      @formatter = proc
    end
    
    def spell 
      StandardError.new("Not Implemented") unless @spell_url
      "#{@spell_url}/"
    end

    def get_limit
      @limit
    end

    # Can be modified by setting `formatter` in the child fetcher
    def format_impact_data(data, credential)
      if @formatter
        HashWithIndifferentAccess.new(@formatter.call(data, credential))
      else 
        HashWithIndifferentAccess.new(data)
      end
    end

    # Meta API returns an array of response, one for each item sent in #fetch_for_user! or #fetch_for_users
    # I call those item response_for_credential because a sent element always correspond to an ApplicationCredential instance 
    def handle_response(response)
      if response.success? 
        responses_by_credentials = response.body[:data]
        if responses_by_credentials.kind_of? Array

          responses_by_credentials.each do |response_for_credential|
            credential = ApplicationCredential.find_by_request_id(response_for_credential[:id])
            # Can't use == true because doesn't return success if true
            if response_for_credential[:success] != false
              data = format_impact_data(response_for_credential, credential)
              credential.application.fetcher.transmit_to_protocol(credential, data)
              credential.has_synched!
              credential.set_impact_meta_data(data)
            else 
              # TODO: Log & Leave it for the next Observer cycle.
              # Should not raise because we don't want to break the loop and stop there
              puts Api::Meta::Error.new("Failed to retrieve data for request #{credential.last_request_id}.").inspect
            end
          end
        elsif responses_by_credentials.kind_of? Hash # If we have a hash
          # TODO: This whole elsif should not exist waiting for Meta API to change
          response_for_credential = responses_by_credentials
          credential = ApplicationCredential.find_by_request_id(response_for_credential[:id])
            # Can't use == true because doesn't return success if true
            if response_for_credential[:success] != false
              data = format_impact_data(response_for_credential, credential)
              credential.application.fetcher.transmit_to_protocol(credential, data)
              credential.has_synched!
              credential.set_impact_meta_data(data)
            else 
              # TODO: Log & Leave it for the next Observer cycle.
              # Should not raise because we don't want to break the loop and stop there
              puts Api::Meta::Error.new("Failed to retrieve data for request #{credential.last_request_id}.").inspect
            end
          end
      else
        # TODO: Log & Leave it for the next Observer cycle.
        # Should not raise because we don't want to break the loop and stop there
        puts Api::Meta::Error.new("Meta API request failed with #{response.status}.\nMessage: #{response.body[:message]}").inspect
      end
    end
  end

  def initialize
    app_uid_from_class = self.class.to_s.split(/::/)[0..-2].join('').underscore
    @app = Remote::Application.find_by(uid: app_uid_from_class) 

    unless @app 
      # If nothing was found, it means the application is not yet cached, so we make sure we have everything
      @app = Remote::Application.find_all.select { |app| app.uid == app_uid_from_class }      
    end
  end

  # Convenience
  def spell 
    self.class.spell
  end

  def asynchronous?
    self.class.asynchronous?
  end

  def synchronous?
    self.class.synchronous?
  end

  def limit 
    self.class.get_limit
  end

  def did_hit_limit?(credential)
    if limit && credential.last_fetched
      (credential.last_fetched + limit) >= DateTime.now
    else
      false
    end
  end

  # Fetches all impact data for this application for a specific user
  def fetch_for_user!(user)
    credential = user.connected_credentials_for(app.id)
    
    auth_request = credential.generate_auth_request

    unless did_hit_limit?(credential)
      p "=== #fetch_for_user - #{app.uid} ===" if Rails.env.development?
      cast_spell(auth_request)
    end
  end

  # Fetches all impact data for all users for this specific app
  def fetch_for_users!
    auth_requests = app.users_credentials.connected.map do |credential|
      unless did_hit_limit?(credential)
        auth_request = credential.generate_auth_request
        auth_request
      end
    end.compact # remove requests for which we hit the limit that returned nil

    if auth_requests.any?
      p "=== #fetch_for_users - #{app.uid} ===" if Rails.env.development?
      cast_batch_spell(auth_requests)
    end
  end

  def cast_spell(auth_request, options = {})
    if auth_request
      meta_response = ::Api::Meta.cast(spell, { items: [auth_request] }, options.merge({ async: asynchronous? }))

      if synchronous?
        self.class.handle_response(meta_response)
      end
    end
  end

  def cast_batch_spell(auth_requests, options = {})
     # if auth is false or nil we remove it
    auth_requests.reject! { |auth| !auth }

    if auth_requests.any?
      meta_response = ::Api::Meta.cast(spell, { items: auth_requests }, options.merge({ async: asynchronous? }))

      if synchronous?
        self.class.handle_response(meta_response)
      end
    end
  end
end