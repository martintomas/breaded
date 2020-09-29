require 'sidekiq/web'

Rails.application.routes.draw do
  root 'pages#home'

  ActiveAdmin.routes(self)

  authenticate :user, lambda { |u| u.has_role? :admin } do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :users, controllers: { sessions: 'users/sessions', registrations: 'users/registrations', passwords: 'users/passwords' }
end
