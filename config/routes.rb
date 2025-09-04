require "sidekiq/web"

Rails.application.routes.draw do

  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  resources :posts do
    resources :comments
    resources :reactions, only: %i[create], module: :posts do
      delete :destroy, on: :collection
    end
  end

  resources :comments, only: %i[create update destroy] do
    resources :reactions, only: %i[create], module: :comments do
      delete :destroy, on: :collection
    end
  end

  resources :comments, only: [:update, :destroy]

  resource :profile, only: %i[show edit update]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  if Rails.env.development?
    mount Sidekiq::Web => "/sidekiq"
    mount LetterOpenerWeb::Engine, at: "letter_opener"
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "posts#index"
end
