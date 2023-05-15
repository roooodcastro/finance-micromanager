# frozen_string_literal: true

Rails.application.routes.draw do
  defaults export: true do
    root to: 'landings#show'

    devise_for :users,
               export: true,
               path: 'auth',
               controllers: {
                 confirmations: 'users/confirmations',
                 registrations: 'users/registrations',
                 sessions: 'users/sessions',
                 unlocks: 'users/unlocks'
               },
               path_names: {
                 sign_in: 'login',
                 sign_out: 'logout',
                 password: 'secret',
                 confirmation: 'verification',
                 unlock: 'unblock',
                 registration: 'sign_up',
                 sign_up: 'new'
               }

    devise_scope :user do
      get 'sign_up', to: 'users/registrations#new'
      get 'login', to: 'users/sessions#new'
    end

    resource :dashboard, only: :show
    resource :landing, only: :show

    resources :categories
    resources :transactions
  end

  resources :accounts
end
