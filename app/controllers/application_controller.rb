class ApplicationController < ActionController::Base
  protect_from_forgery unless: -> { request.format.json? }

  before_action :set_raven_context

  private

  def set_raven_context 
    if Rails.env.production? && ENV['TEST_MODE'] # TODO: Improve and create a real staging env
      environment = "staging"
    elsif Rails.env.production? 
      environment = "production"
    else
      environment = "development"
    end

    Raven.user_context(id: session[:current_user_id]) # or anything else in session
    Raven.extra_context(params: params.to_unsafe_h, url: request.url, environment: environment)
  end
end
