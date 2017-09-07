# frozen_string_literal: true

RailsWorkflow::Engine.routes.draw do
  resources :operations, only: %i[index show] do
    collection do
      get :complete
      get :skip
      get :postpone
      get :cancel
      get :navigate_to
    end

    member do
      get :continue
      put :pickup
    end
  end

  resources :processes, except: [:destroy] do
    resources :errors, only: [:retry] do
      member do
        put :retry
      end
    end
    resources :operations, except: %i[create update destroy] do
      resources :errors, only: [:retry] do
        member do
          put :retry
        end
      end
    end
  end

  resources :process_templates, path: 'config' do
    resources :operation_templates
    member do
      get :export
    end
    collection do
      post :upload
    end
  end
  root to: 'operations#index'
end
