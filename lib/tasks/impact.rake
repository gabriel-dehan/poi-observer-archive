namespace :impact do
  desc "rake impact:refresh"
  task refresh: :environment do
    RefreshImpactJob.perform_later
  end
end
