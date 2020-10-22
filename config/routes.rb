require 'sidekiq/web'

Rails.application.routes.draw do
  root 'pages#home'

  ActiveAdmin.routes(self)

  authenticate :user, lambda { |u| u.has_role? :admin } do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :users, controllers: { sessions: 'users/sessions', registrations: 'users/registrations', passwords: 'users/passwords' }

  resources :foods, only: %i[index show]  do
    collection do
      get :surprise_me
    end
  end

  resources :subscriptions, only: %i[new create] do
    member do
      get :checkout
    end
  end

  resources :stripe, only: %i[] do
    collection do
      post :checkout_session
      post :subscription_webhook
    end
  end

  resources :producer_applications, only: %i[new create]
  resources :users, only: %i[show]
end
