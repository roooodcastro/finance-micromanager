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
    resource :profile, only: %i[show update]

    resources :wallets
    resources :wallet_share_invites_sent, except: %i[show new edit update]
    resources :wallet_share_invites_received, only: %i[index update destroy]
    resources :categories, except: %i[show]
    resources :currencies, only: %i[index]
    resources :current_wallets, only: %i[create]
    resources :locales, only: %i[index]
    resources :transactions, except: %i[show]
  end

  resource :health_check, only: :show
end
