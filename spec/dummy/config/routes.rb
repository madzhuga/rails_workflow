# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web, at: '/sidekiq'
  resources :leads

  resources :sales_contacts

  devise_for :users
  mount RailsWorkflow::Engine => '/workflow', as: 'workflow'
end
