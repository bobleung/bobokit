Rails.application.routes.draw do
  resources :jobs
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
  resources :organisations, only: [ :new, :create, :show, :edit, :update ] do
    member do
      post :invite_member
      delete :remove_member
      patch :change_member_role
      patch :deactivate
    end
  end

  # Memberships (invitation actions)
  resources :memberships, only: [] do
    member do
      post :accept
      post :decline
    end
  end

  # Super Admin Pages
  get "super/users", to: "super_admin#users"
  post "super/users", to: "super_admin#create_user"
  patch "super/users/:id", to: "super_admin#update_user"
  delete "super/users/:id", to: "super_admin#destroy_user"
  get "super/orgs", to: "super_admin#orgs"
  patch "super/orgs/:id", to: "super_admin#update_org"
  delete "super/orgs/:id", to: "super_admin#destroy_org"
end

# Jobs
resources :jobs
