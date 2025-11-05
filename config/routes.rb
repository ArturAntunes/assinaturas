Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Root
  root "pages#home"

  # Authentication
  get    '/login',  to: 'sessions#new',     as: :login
  post   '/login',  to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy', as: :logout

  # Registration
  get  '/register', to: 'registrations#new',    as: :register
  post '/register', to: 'registrations#create'

  # Admin Area
  namespace :admin do
    get '/', to: 'dashboard#index', as: :dashboard
    
    resources :plans do
      member do
        patch :toggle_active
      end
    end
    
    resources :subscriptions, only: [:index, :show] do
      member do
        patch :cancel
      end
    end
    
    resources :invoices, only: [:index, :show]
  end

  # Customer Area
  namespace :customer do
    get '/', to: 'dashboard#index', as: :dashboard
    
    resources :plans, only: [:index]
    
    resources :subscriptions, only: [:create, :show] do
      member do
        patch :cancel
      end
    end
    
    resources :invoices, only: [:index, :show] do
      member do
        patch :pay
      end
    end
  end

  # API v1
  namespace :api do
    namespace :v1 do
      resources :plans, only: [:index]
      
      resources :subscriptions, only: [:create] do
        collection do
          get :me
          delete :cancel
        end
      end
      
      resources :invoices, only: [:index, :show] do
        member do
          post :pay
        end
      end
    end
  end
end
