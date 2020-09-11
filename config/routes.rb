Rails.application.routes.draw do
  root 'pages#home'

  resources :pages do
    collection do
      get :commit
    end
  end
end
