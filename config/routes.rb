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
  resources :applications, only: %i[index show new create] do
    member do
      patch :withdraw
      patch :shortlist
      patch :reject
      patch :accept
    end
  end

  resources :applications, only: [] do
  resources :visits, only: %i[new create]
end

resources :visits, only: %i[show edit update] do
  member do
    patch :confirm
    patch :cancel
    patch :complete
  end
end

  resources :visits, only: [] do
    resources :reviews, only: %i[new create]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end