# frozen_string_literal: true

Rails.application.routes.draw do
  resources :categories
  resources :transactions
  resources :accounts
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
