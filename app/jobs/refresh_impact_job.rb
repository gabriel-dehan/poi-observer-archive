class RefreshImpactJob < ApplicationJob
  queue_as :default

  def perform(app_filter = nil)
    # We make sure we retrieve all applications by passing a per_page params with an absurd amount
    # TODO: Cache in local DB and refresh maybe once a day ?
    # applications = Api::Poi::client.get('/v1/applications', { per_page: 10000 }).data

    applications = Remote::Application.find_all

    if app_filter 
      app = applications.find { |app| app.uid == app_filter }
      app.fetch_impact_data!
    else
      applications.each do |app| 
        app.fetch_impact_data!
      end
    end
  end
end
