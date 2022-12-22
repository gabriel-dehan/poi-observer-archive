Rails.application.routes.draw do
  devise_for :users

  root to: "pages#home"

  require "sidekiq/web"
  authenticate :user, lambda { |u| u.admin } do
    mount Sidekiq::Web => '/sidekiq'
  end

  post '/users/:id/validate_auth', to: "users#validate_auth"
  post '/users/:id/refresh', to: "users#refresh"
  post '/webhooks/spells', to: "webhooks#spells"
end
