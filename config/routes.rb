# frozen_string_literal: true

Rails.application.routes.draw do
  resources :categories, export: true
  resources :transactions, export: true

  resources :accounts
end
