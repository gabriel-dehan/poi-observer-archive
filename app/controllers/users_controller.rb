class UsersController < ApplicationController  
  def refresh 
    user_id = params[:id]
    user = Remote::User.find(user_id)
    # If there is not latest_update, we just say it's been updated yesterday to ensure a refresh
    latest_update = user.application_credentials.pluck(:last_fetched).compact.sort.last || (DateTime.now - 1.day)

    # Prevent the refresh from being done more than once every 10 minutes
    if (latest_update + 10.minutes) <= DateTime.now || Rails.env.development?
      p "Refreshing Impact for user #{user_id}"
      RefreshUserImpactJob.perform_later(user_id)
    end
  end

  def validate_auth 
    user_id = params[:id]
    application_id = params[:credentials][:application_id]
    email = params[:credentials][:email]
    password = params[:credentials][:encrypted_password]

    can_auth = false 
    
    if application_id && email && password
      credential = ApplicationCredential.new(
        email: email,
        encrypted_password: password,
        application_id: application_id  
      )

      can_auth = credential.authentifier.can_auth?
    end

    render json: { authorized: can_auth }, status: 200
  end
end