Rails.application.routes.draw do
  get "messages/create"
  get "messages/destroy"
  get "conversations/index"
  get "conversations/show"
  get "conversations/create"
  # get "users/index"
  # get "users/show"
  # get "users/edit"
  # get "users/update"
  # get "posts/index"
  # get "posts/show"
  # get "posts/new"
  # get "posts/create"
  # get "posts/edit"
  # get "posts/update"
  # get "posts/destroy"
  devise_for :users
  root 'pages#index'

  resources :posts
  resources :categories, only: [:index, :show]

  resources :users, only: [:show, :edit, :update], path: 'people', constraints: { id: /\d+/ }
  get 'people', to: 'users#index', as: 'users'
  resources :contacts, only: [:index, :create, :update, :destroy]

  get 'conversations/start', to: 'conversations#start', as: 'start_conversation'

  resources :conversations, only: [:index, :show, :create] do
    resources :messages, only: [:create, :destroy]
  end

  #get 'conversations/start', to: 'conversations#start', as: 'start_conversation'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  get '/login', to: 'devise/sessions#new'
  get '/signup', to: 'devise/registrations#new'
end
