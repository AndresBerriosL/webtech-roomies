Rails.application.routes.draw do
  root "home#index"

  resources :listings, only: %i[index show]
  resources :properties
  resources :neighborhoods
  resources :amenities
  resources :applications, only: %i[index show]

  get "up" => "rails/health#show", as: :rails_health_check
end