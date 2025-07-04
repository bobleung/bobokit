Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  get "inertia-example", to: "inertia_example#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "inertia_example#index"

  get "signup", to: "users#new"
  get "login", to: "sessions#new"
  get "logout", to: "sessions#destroy"
  get "profile", to: "users#profile"
  patch "profile", to: "users#update_profile"
  resources :users
  
  # Email verification routes
  get "email_verification", to: "email_verifications#show"
  get "verify_email", to: "email_verifications#verify"
  post "resend_verification", to: "email_verifications#resend"
  
  # User context switching
  post "user/switch_context", to: "user_context#switch_context"
  
  # Organisations
  resources :organisations, only: [:new, :create, :show, :edit, :update]
end
