class RefreshUserImpactJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = Remote::User.find(user_id)

    user.fetch_impact_data!    
  end
end
