require 'sidekiq/web'

Rails.application.routes.draw do
  root 'pages#home'

  mount Sidekiq::Web => '/sidekiq'

  resources :pages do
    collection do
      get :commit
    end
  end
end
