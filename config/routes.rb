RailsWorkflow::Engine.routes.draw do

  resources :operations do
    member do
      get :complete
      get :skip
      get :continue
      put :pickup
      get :cancel
    end
  end


  resources :processes, except: [:destroy] do
    resources :errors, only: [:retry] do
      member do
        put :retry
      end
    end
    resources :operations, except: [:destroy] do
      resources :errors, only: [:retry] do
        member do
          put :retry
        end
      end
    end
  end

  resources :process_templates, path: 'config' do
    resources :operation_templates
  end
  root to: 'operations#index'
end
