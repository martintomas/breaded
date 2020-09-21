require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users
  root 'pages#home'

  authenticate :user, lambda { |u| u.has_role? :admin } do
    mount Sidekiq::Web => '/sidekiq'
  end

  resources :pages do
    collection do
      get :commit
    end
  end
end
