require 'sidekiq/web'
require 'sidekiq-scheduler/web'

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
  resources :subscriptions, only: %i[new create edit update show] do
    member do
      get :cancel
      get :resume
    end
    scope module: :subscriptions do
      resources :payments, only: %i[new show edit]
    end
  end
  resources :subscription_periods, only: %i[show]
  resources :orders, only: %i[show update edit] do
    member do
      post :update_date
      post :update_address
      post :pick_breads_option
      post :copy_order_option
      post :confirm_copy_option
      get :confirm_update
      get :surprise_me
    end
  end
  resources :stripe, only: %i[] do
    collection do
      post :checkout_session
      post :subscription_webhook
      post :create_subscription
      post :update_payment_method
    end
  end
  resources :twilio, only: %i[] do
    collection do
      post :sent_verification_sms
      post :verify_phone_number
    end
  end
  resources :producer_applications, only: %i[new create]
  resources :users, only: %i[show] do
    collection do
      get :my_boxes
      get :my_plan
      get :my_payment
    end
  end
  resources :addresses do
    member do
      get :set_as_main
    end
  end
end
