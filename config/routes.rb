Rails.application.routes.draw do
  # namespace :api do
  # get 'declined_transaction_status/show'
  # end

  resources :dashboards
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'dashboards#index'
  get  'about' => 'dashboards#about'

  namespace :api do
    post 'c2k_trans' => 'c2k_trans#create'
    resources :declined_transaction_status, only: [:index, :show]
  end

  match "/delayed_job" => DelayedJobWeb, :anchor => false, via: [:get, :post]
end
