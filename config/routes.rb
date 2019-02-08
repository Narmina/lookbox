  Rails.application.routes.draw do

  root_path = 'home#index'

  devise_for :users, skip: [:session, :password, :registration, :confirmation], controllers: { omniauth_callbacks: 'omniauth_callbacks' }

  get '/users/auth/:provider' => 'omniauth_sessions#create', as: 'omniauth_authorize'

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  scope '(:locale)', locale: /#{I18n.available_locales.join('|')}/ do

    devise_scope :user do
      get 'omniauth/:provider' => 'omniauth_callbacks#localized', as: :localized_omniauth
    end

      devise_for :users, skip: :omniauth_callbacks


      get 'users/change_password'
      put 'users/save_password' => 'users#save_password'

      resources :pictures do
        get 'refresh', on: :collection
        get 'copy', on: :member
      end

      resources :looks do
         collection do
           get 'autocomplete_user_email'
           get 'shared'
         end
         member do
            post 'add_pictures'
            get 'approve_shared'
            get 'remove_shared'
         end
     end

      resources :categories do
        get 'available_pictures', on: :member
        post 'add_pictures', on: :member
      end

      resources :user_settings do
        collection do
          get 'change'
          put 'save'
        end
      end

      get 'api_keys/access_token' => 'api_keys#recreate_access_token'

      get 'users/profile', as: 'user_root'
      root to: root_path

      mount External::ApiVersion1 => '/'

      match '*path', :to => 'application#path_not_found', via: [:get, :post]
  end

end



