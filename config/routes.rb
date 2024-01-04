# frozen_string_literal: true

Rails.application.routes.draw do
  defaults export: true do
    devise_for :users,
               export:      true,
               path:        'auth',
               controllers: {
                 confirmations: 'users/confirmations',
                 passwords:     'users/passwords',
                 registrations: 'users/registrations',
                 sessions:      'users/sessions',
                 unlocks:       'users/unlocks'
               },
               path_names:  {
                 sign_in:      'login',
                 sign_out:     'logout',
                 password:     'secret',
                 confirmation: 'verification',
                 unlock:       'unblock',
                 registration: 'sign_up',
                 sign_up:      'new'
               }

    devise_scope :user do
      get 'sign_up', to: 'users/registrations#new', export: true
      get 'login', to: 'users/sessions#new', export: true
    end

    authenticated :user do
      root 'dashboards#show', as: :user_root
    end

    unauthenticated :user do
      root to: 'landings#show', as: :public_root
    end

    resource :dashboard, only: :show
    resource :landing, only: :show
    resource :setting, only: %i[show update]

    resources :profiles
    resources :profile_share_invites_sent, except: %i[show new edit update]
    resources :profile_share_invites_received, only: %i[index update destroy]
    resources :categories, only: %i[index show create update destroy] do
      resources :subcategories, only: %i[index create update destroy] do
        patch :reenable, on: :member
      end
    end
    resources :currencies, only: %i[index]
    resources :current_profiles, only: %i[create]
    resources :locales, only: %i[index]
    resources :transactions, except: %i[show] do
      patch :update_all, on: :collection
    end
    resources :wallets, only: %i[index create update destroy] do
      patch :reenable, on: :member
    end

    resources :reconciliations, only: %i[index show create update destroy] do
      patch :finish, on: :member
      resources :reconciliations_wallets, only: :create
    end

    namespace :statistics do
      resources :category_summaries, only: %i[index]
    end
  end

  resource :health_check, only: :show
end
