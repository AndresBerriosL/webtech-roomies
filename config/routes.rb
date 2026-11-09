Rails.application.routes.draw do
  resource :profile, only: %i[edit update]



  namespace :api do
    namespace :v1 do
      resources :listings, only: %i[index show]
    end
  end



  resources :listings, only: [] do
    resources :reports, only: %i[new create]
  end

  resources :reports, only: %i[index] do
    member do
      patch :resolve
    end
  end

  
  resources :passwords, param: :token, only: %i[new create edit update]

  resource :session, only: %i[new create destroy]

  resource :registration, only: %i[new create]
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

  
  resources :visits, only: [] do
    resources :reviews, only: %i[new create]
  end

  resources :reviews, only: %i[destroy]


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