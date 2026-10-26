Rails.application.routes.draw do
  root "home#index"

  
  resources :listings, only: %i[index show edit update destroy] do
    member do
      patch :publish
      patch :withdraw
    end
  end
  resources :properties do
    resources :listings, only: %i[new create]
  end

  resources :neighborhoods
  resources :amenities
  resources :applications, only: %i[index show]

  get "up" => "rails/health#show", as: :rails_health_check
end