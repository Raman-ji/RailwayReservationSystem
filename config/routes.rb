Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  resources :availabilities
  resources :searches
  resources :train_details
  resources :reservations, only: %i[new create destroy]
  root 'searches#new'
  post '/wait_list', to: 'searches#wait_list'
  get '/wait_list', to: 'searches#wait_list'
  post '/confirm_list', to: 'searches#confirm_list'
  get '/confirm_list', to: 'searches#confirm_list'
  get 'payment', to: 'reservations#create', as: :payment
  resources :reservations do
    member do
      delete 'confirm', to: 'reservations#destroy_confirm'
      delete 'waitlist', to: 'reservations#destroy_wait_list'
    end
  end  
end
