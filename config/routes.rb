Rails.application.routes.draw do
  resources :dashboards
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'dashboards#index'
  get  'about' => 'dashboards#about'

  namespace :api do
    post 'c2k_trans' => 'c2k_trans#create'
  end

  match "/delayed_job" => DelayedJobWeb, :anchor => false, via: [:get, :post]
end
