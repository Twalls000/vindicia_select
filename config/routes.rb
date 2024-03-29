Rails.application.routes.draw do
  resources :app_configs
  # namespace :api do
  # get 'declined_transaction_status/show'
  # end

  resources :dashboards
  namespace :dashboards do
    resources :market_publications, only: :show
  end
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'dashboards#index'
  get  'about' => 'dashboards#about'

  namespace :api do
    post 'c2k_trans' => 'c2k_trans#create'
    get 'declined_transaction_status/:id' => 'declined_transaction_status#show', format: :json
  end

  match "/delayed_job" => DelayedJobWeb, :anchor => false, via: [:get, :post]
end
