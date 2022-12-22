class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def spells 
    # TODO: Make sure it comes from meta api
    meta_response = Api::Meta::AsyncResponse.new(params.permit!.to_h)

    if meta_response.body[:data].any?
      # Find the correct application's fetcher
      fetcher = ApplicationCredential.find_by_request_id(meta_response.body[:data].first["id"]).application.fetcher.class
      fetcher.handle_response(meta_response)
    end
  end
end